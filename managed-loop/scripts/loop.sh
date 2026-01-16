#!/bin/bash
#
# loop.sh - Run Claude in a loop with fresh context per iteration
#
# USAGE:
#   /loop "Task description"
#   /loop                      # Prompts for task
#   /loop session-name         # Resume existing session
#
# Based on Ralph Wiggum pattern and Anthropic's context engineering.
#

set -euo pipefail

if ! command -v claude &>/dev/null; then
  echo "Error: claude CLI not found." >&2
  exit 1
fi

BASE_DIR="${LOOPER_DIR:-.looper}"
MAX="${LOOPER_MAX:-10}"

# Check if arg is an existing session to resume
if [[ -n "${1:-}" && -d "$BASE_DIR/$1" ]]; then
  SESSION_NAME="$1"
  LOOP_DIR="$BASE_DIR/$SESSION_NAME"
  echo "Resuming session: $SESSION_NAME"
else
  # New task
  if [[ -n "${1:-}" ]]; then
    TASK="$*"
  else
    echo -n "Task: "
    read -r TASK
    if [[ -z "$TASK" ]]; then
      echo "Error: Task required." >&2
      exit 1
    fi
  fi

  SESSION_NAME="$(date +%m%d-%H%M%S)"
  LOOP_DIR="$BASE_DIR/$SESSION_NAME"

  mkdir -p "$LOOP_DIR"

  # Auto-add to .gitignore
  if [[ -d .git && "$BASE_DIR" == ".looper" ]]; then
    if [[ ! -f .gitignore ]] || ! grep -qF ".looper/" .gitignore; then
      echo ".looper/" >> .gitignore
    fi
  fi

  cat > "$LOOP_DIR/PROMPT.md" << EOF
@$LOOP_DIR/plan.md @$LOOP_DIR/activity.md

Do the next unchecked task in plan.md.
Log progress in activity.md, check off the task.

When all tasks checked: <promise>COMPLETE</promise>
EOF

  cat > "$LOOP_DIR/plan.md" << EOF
# Plan

- [ ] $TASK
EOF

  cat > "$LOOP_DIR/activity.md" << 'EOF'
# Activity Log
EOF

  echo "Session: $SESSION_NAME"
fi

PROMPT_FILE="$LOOP_DIR/PROMPT.md"
trap 'echo ""; echo "Stopped. Resume: /loop $SESSION_NAME"' INT

# Settings
SETTINGS_ARG=""
if [[ -f ".claude/settings.json" && -f ".claude/settings.local.json" ]]; then
  if command -v jq &>/dev/null; then
    MERGED="$LOOP_DIR/.merged-settings.json"
    jq -s '.[0] * .[1]' .claude/settings.json .claude/settings.local.json > "$MERGED" 2>/dev/null && SETTINGS_ARG="--settings $MERGED"
  fi
  [[ -z "$SETTINGS_ARG" ]] && SETTINGS_ARG="--settings .claude/settings.json"
elif [[ -f ".claude/settings.local.json" ]]; then
  SETTINGS_ARG="--settings .claude/settings.local.json"
elif [[ -f ".claude/settings.json" ]]; then
  SETTINGS_ARG="--settings .claude/settings.json"
fi

[[ -z "$SETTINGS_ARG" ]] && echo "Warning: No .claude/settings.json - may hang on prompts." >&2

for ((i=1; i<=MAX; i++)); do
  DONE=$(grep -c '\- \[x\]' "$LOOP_DIR/plan.md" 2>/dev/null || true)
  TODO=$(grep -c '\- \[ \]' "$LOOP_DIR/plan.md" 2>/dev/null || true)
  DONE=${DONE:-0}
  TODO=${TODO:-0}
  echo "--- Iteration $i/$MAX ($DONE/$((DONE+TODO)) done) ---"

  # shellcheck disable=SC2086
  if result=$(claude -p $SETTINGS_ARG "$(cat "$PROMPT_FILE")"); then
    echo "$result"
  else
    echo "Error: claude failed" >&2
    continue
  fi

  if [[ "$result" == *"<promise>COMPLETE</promise>"* ]]; then
    echo "Done after $i iteration(s)."
    exit 0
  fi
done

echo "Reached $MAX iterations. Resume: /loop $SESSION_NAME"
