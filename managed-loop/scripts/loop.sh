#!/bin/bash

# loop.sh - Run Claude in a loop with fresh context per iteration
# Usage: ./loop.sh <iterations> [--dry-run]

set -euo pipefail

DRY_RUN=false
MAX=""
ERRORS=0
COMPLETED=0
START_TIME=$SECONDS

cleanup() {
  total=$((SECONDS - START_TIME))
  echo ""
  echo "Interrupted after $COMPLETED iterations in ${total}s. ($ERRORS errors)"
  exit 130
}
trap cleanup SIGINT SIGTERM

for arg in "$@"; do
  case $arg in
    --dry-run) DRY_RUN=true ;;
    *) [[ -z "$MAX" ]] && MAX="$arg" ;;
  esac
done

[[ -z "$MAX" ]] && echo "Usage: ./loop.sh <iterations> [--dry-run]" && exit 1
[[ ! -f "PROMPT.md" ]] && echo "Error: PROMPT.md not found" && exit 1

if $DRY_RUN; then
  echo "=== DRY RUN ==="
  echo "Would run $MAX iterations with prompt:"
  echo "---"
  cat PROMPT.md
  echo "---"
  exit 0
fi

for ((i=1; i<=MAX; i++)); do
  iter_start=$SECONDS
  echo "--- Iteration $i / $MAX ---"

  if result=$(claude -p "$(cat PROMPT.md)" 2>&1); then
    echo "$result"
  else
    echo "Error in iteration $i (continuing): $result"
    ((ERRORS++))
    continue
  fi

  ((COMPLETED++))
  elapsed=$((SECONDS - iter_start))
  echo "[${elapsed}s]"

  if [[ "$result" == *"<promise>COMPLETE</promise>"* ]]; then
    total=$((SECONDS - START_TIME))
    echo ""
    echo "Complete after $i iterations in ${total}s. ($ERRORS errors)"
    exit 0
  fi
  echo ""
done

total=$((SECONDS - START_TIME))
echo "Reached max iterations ($MAX) in ${total}s. ($ERRORS errors)"
