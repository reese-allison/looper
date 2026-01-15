#!/bin/bash

# Managed Loop Stop Hook
# Prevents session exit when a managed loop is active
# Feeds the prompt back as input to continue the loop

set -euo pipefail

# Read hook input from stdin (advanced stop hook API)
HOOK_INPUT=$(cat)

# Check if loop is active
LOOP_STATE_FILE=".claude/loop-state.local.md"

if [[ ! -f "$LOOP_STATE_FILE" ]]; then
  # No active loop - allow exit
  exit 0
fi

# Parse markdown frontmatter (YAML between ---) and extract values
FRONTMATTER=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' "$LOOP_STATE_FILE")
ITERATION=$(echo "$FRONTMATTER" | grep '^iteration:' | sed 's/iteration: *//')
MAX_ITERATIONS=$(echo "$FRONTMATTER" | grep '^max_iterations:' | sed 's/max_iterations: *//')
COMPLETION_PROMISE=$(echo "$FRONTMATTER" | grep '^completion_promise:' | sed 's/completion_promise: *//' | sed 's/^"\(.*\)"$/\1/')
GIT_ENABLED=$(echo "$FRONTMATTER" | grep '^git_enabled:' | sed 's/git_enabled: *//')
VERIFY_ENABLED=$(echo "$FRONTMATTER" | grep '^verify_enabled:' | sed 's/verify_enabled: *//')
TASK_MODE=$(echo "$FRONTMATTER" | grep '^task_mode:' | sed 's/task_mode: *//')

# Validate numeric fields before arithmetic operations
if [[ ! "$ITERATION" =~ ^[0-9]+$ ]]; then
  echo "Loop state file corrupted (invalid iteration: '$ITERATION')" >&2
  echo "Loop is stopping. Run /loop again to start fresh." >&2
  rm "$LOOP_STATE_FILE"
  exit 0
fi

if [[ ! "$MAX_ITERATIONS" =~ ^[0-9]+$ ]]; then
  echo "Loop state file corrupted (invalid max_iterations: '$MAX_ITERATIONS')" >&2
  echo "Loop is stopping. Run /loop again to start fresh." >&2
  rm "$LOOP_STATE_FILE"
  exit 0
fi

# Check if max iterations reached
if [[ $MAX_ITERATIONS -gt 0 ]] && [[ $ITERATION -ge $MAX_ITERATIONS ]]; then
  echo "Max iterations ($MAX_ITERATIONS) reached. Loop complete."
  rm "$LOOP_STATE_FILE"
  exit 0
fi

# Get transcript path from hook input
TRANSCRIPT_PATH=$(echo "$HOOK_INPUT" | jq -r '.transcript_path')

if [[ ! -f "$TRANSCRIPT_PATH" ]]; then
  echo "Transcript file not found. Loop is stopping." >&2
  rm "$LOOP_STATE_FILE"
  exit 0
fi

# Read last assistant message from transcript (JSONL format)
if ! grep -q '"role":"assistant"' "$TRANSCRIPT_PATH"; then
  echo "No assistant messages found. Loop is stopping." >&2
  rm "$LOOP_STATE_FILE"
  exit 0
fi

# Extract last assistant message
LAST_LINE=$(grep '"role":"assistant"' "$TRANSCRIPT_PATH" | tail -1)
if [[ -z "$LAST_LINE" ]]; then
  echo "Failed to extract last assistant message. Loop is stopping." >&2
  rm "$LOOP_STATE_FILE"
  exit 0
fi

# Parse JSON with error handling
LAST_OUTPUT=$(echo "$LAST_LINE" | jq -r '
  .message.content |
  map(select(.type == "text")) |
  map(.text) |
  join("\n")
' 2>&1)

if [[ $? -ne 0 ]]; then
  echo "Failed to parse assistant message. Loop is stopping." >&2
  rm "$LOOP_STATE_FILE"
  exit 0
fi

if [[ -z "$LAST_OUTPUT" ]]; then
  echo "Assistant message contained no text. Loop is stopping." >&2
  rm "$LOOP_STATE_FILE"
  exit 0
fi

# Check for completion promise (only if set)
if [[ "$COMPLETION_PROMISE" != "null" ]] && [[ -n "$COMPLETION_PROMISE" ]]; then
  # Extract text from <promise> tags using Perl for multiline support
  PROMISE_TEXT=$(echo "$LAST_OUTPUT" | perl -0777 -pe 's/.*?<promise>(.*?)<\/promise>.*/$1/s; s/^\s+|\s+$//g; s/\s+/ /g' 2>/dev/null || echo "")

  # Use = for literal string comparison
  if [[ -n "$PROMISE_TEXT" ]] && [[ "$PROMISE_TEXT" = "$COMPLETION_PROMISE" ]]; then
    echo "Completion promise detected: <promise>$COMPLETION_PROMISE</promise>"
    echo "Loop complete!"
    rm "$LOOP_STATE_FILE"
    exit 0
  fi
fi

# Not complete - continue loop with SAME PROMPT
NEXT_ITERATION=$((ITERATION + 1))

# Extract prompt (everything after the closing ---)
PROMPT_TEXT=$(awk '/^---$/{i++; next} i>=2' "$LOOP_STATE_FILE")

if [[ -z "$PROMPT_TEXT" ]]; then
  echo "Loop state file corrupted (no prompt found). Loop is stopping." >&2
  rm "$LOOP_STATE_FILE"
  exit 0
fi

# Update iteration in frontmatter
TEMP_FILE="${LOOP_STATE_FILE}.tmp.$$"
sed "s/^iteration: .*/iteration: $NEXT_ITERATION/" "$LOOP_STATE_FILE" > "$TEMP_FILE"
mv "$TEMP_FILE" "$LOOP_STATE_FILE"

# Build system message with iteration count and options
SYSTEM_MSG="Iteration $NEXT_ITERATION"

if [[ $MAX_ITERATIONS -gt 0 ]]; then
  SYSTEM_MSG="$SYSTEM_MSG / $MAX_ITERATIONS"
fi

if [[ "$COMPLETION_PROMISE" != "null" ]] && [[ -n "$COMPLETION_PROMISE" ]]; then
  SYSTEM_MSG="$SYSTEM_MSG | Complete: <promise>$COMPLETION_PROMISE</promise>"
fi

# Add optional feature reminders
FEATURE_REMINDERS=""

if [[ "$GIT_ENABLED" == "true" ]]; then
  FEATURE_REMINDERS="$FEATURE_REMINDERS\n[Git enabled - commit completed work]"
fi

if [[ "$VERIFY_ENABLED" == "true" ]]; then
  FEATURE_REMINDERS="$FEATURE_REMINDERS\n[Verification enabled - confirm work with screenshots/tests]"
fi

if [[ "$TASK_MODE" == "true" ]]; then
  FEATURE_REMINDERS="$FEATURE_REMINDERS\n[Task mode - work on one task from plan.md at a time]"
fi

if [[ -n "$FEATURE_REMINDERS" ]]; then
  SYSTEM_MSG="$SYSTEM_MSG$FEATURE_REMINDERS"
fi

# Output JSON to block the stop and feed prompt back
jq -n \
  --arg prompt "$PROMPT_TEXT" \
  --arg msg "$SYSTEM_MSG" \
  '{
    "decision": "block",
    "reason": $prompt,
    "systemMessage": $msg
  }'

exit 0
