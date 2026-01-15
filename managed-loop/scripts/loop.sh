#!/bin/bash
# Run Claude in a loop with fresh context per iteration

set -euo pipefail

LOOP_DIR="${LOOPER_DIR:-.looper}"
mkdir -p "$LOOP_DIR"

# Auto-add to .gitignore if in a git repo
if [[ -d .git ]] && ! grep -q "^\.looper/?$" .gitignore 2>/dev/null; then
  echo ".looper/" >> .gitignore
fi

MAX=${1:-10}
PROMPT_FILE="$LOOP_DIR/PROMPT.md"

if [[ ! -f "$PROMPT_FILE" ]]; then
  cat > "$LOOP_DIR/PROMPT.md" << 'EOF'
@.looper/plan.md @.looper/activity.md

Do the next unchecked task in plan.md.
Log progress in activity.md, check off the task.

When all tasks checked: <promise>COMPLETE</promise>
EOF
  cat > "$LOOP_DIR/plan.md" << 'EOF'
# Plan

- [ ] First task
- [ ] Second task
EOF
  cat > "$LOOP_DIR/activity.md" << 'EOF'
# Activity Log
EOF
  echo "Created loop files in: $LOOP_DIR/"
  echo "Edit $LOOP_DIR/plan.md with your tasks, then run again."
  exit 0
fi

trap 'echo ""; echo "Stopped. Files in: $LOOP_DIR/"' INT

for ((i=1; i<=MAX; i++)); do
  echo "--- Iteration $i / $MAX ---"

  if result=$(claude -p "$(cat "$PROMPT_FILE")" 2>&1); then
    echo "$result"
  else
    echo "Error: $result"
    continue
  fi

  [[ "$result" == *"<promise>COMPLETE</promise>"* ]] && echo "Done." && exit 0
done

echo "Reached $MAX iterations. Files in: $LOOP_DIR/"
