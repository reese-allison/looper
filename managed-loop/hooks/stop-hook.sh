#!/bin/bash

# Stop hook - continues loop until max iterations or completion
set -euo pipefail

STATE=".claude/loop-state.local.md"
[[ ! -f "$STATE" ]] && exit 0

# Parse state
ITER=$(sed -n 's/^iteration: *//p' "$STATE")
MAX=$(sed -n 's/^max: *//p' "$STATE")

[[ ! "$ITER" =~ ^[0-9]+$ ]] && rm "$STATE" && exit 0
[[ $ITER -ge $MAX ]] && echo "Max iterations reached" && rm "$STATE" && exit 0

# Check for completion in transcript
HOOK_INPUT=$(cat)
TRANSCRIPT=$(echo "$HOOK_INPUT" | jq -r '.transcript_path')

if [[ -f "$TRANSCRIPT" ]]; then
  LAST=$(grep '"role":"assistant"' "$TRANSCRIPT" | tail -1 | jq -r '.message.content | map(select(.type == "text")) | map(.text) | join("")' 2>/dev/null || echo "")
  if [[ "$LAST" == *"<promise>COMPLETE</promise>"* ]]; then
    echo "Complete"
    rm "$STATE"
    exit 0
  fi
fi

# Continue
NEXT=$((ITER + 1))
PROMPT=$(awk '/^---$/{i++; next} i>=2' "$STATE")

sed -i.bak "s/^iteration:.*/iteration: $NEXT/" "$STATE" && rm -f "$STATE.bak"

jq -n --arg p "$PROMPT" --arg m "Iteration $NEXT / $MAX" \
  '{"decision":"block","reason":$p,"systemMessage":$m}'
