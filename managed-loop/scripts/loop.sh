#!/bin/bash
#
# loop.sh - Run Claude in a loop with fresh context per iteration
#
# USAGE:
#   ./loop.sh [max-iterations]
#   /loop [max-iterations]
#
# ARGUMENTS:
#   max-iterations  Maximum loop iterations (default: 10)
#
# ENVIRONMENT:
#   LOOPER_DIR      Directory for loop files (default: .looper)
#
# SETTINGS:
#   If .claude/settings.json and .claude/settings.local.json both exist,
#   they are merged with jq (local overrides base via shallow merge).
#   Without jq, only settings.json is used.
#
# DEPENDENCIES:
#   - bash 4.0+
#   - claude CLI (https://github.com/anthropics/claude-code)
#   - jq (optional, for merging settings files)
#
# EXAMPLES:
#   ./loop.sh 20              # Run up to 20 iterations
#   LOOPER_DIR=~/proj/.looper ./loop.sh 5
#
# BEHAVIOR:
#   First run creates PROMPT.md, plan.md, activity.md in LOOPER_DIR.
#   Edit plan.md with tasks, run again. Each iteration:
#   1. Spawns fresh claude -p with PROMPT.md content
#   2. Claude reads plan.md/activity.md via @ references
#   3. Does one task, logs to activity.md, checks off in plan.md
#   4. Outputs <promise>COMPLETE</promise> when all tasks done
#   Loop exits on COMPLETE or max iterations.
#
# Based on Ralph Wiggum pattern and Anthropic's context engineering.
#

set -euo pipefail

# Verify dependencies
if ! command -v claude &>/dev/null; then
  echo "Error: claude CLI not found. Install from https://github.com/anthropics/claude-code" >&2
  exit 1
fi

LOOP_DIR="${LOOPER_DIR:-.looper}"
mkdir -p "$LOOP_DIR"

# Auto-add to .gitignore if in a git repo and using default .looper dir
if [[ -d .git && "$LOOP_DIR" == ".looper" ]]; then
  if [[ ! -f .gitignore ]] || ! grep -qF ".looper/" .gitignore; then
    echo ".looper/" >> .gitignore
  fi
fi

MAX=${1:-10}
PROMPT_FILE="$LOOP_DIR/PROMPT.md"

if [[ ! -f "$PROMPT_FILE" ]]; then
  cat > "$PROMPT_FILE" << EOF
@$LOOP_DIR/plan.md @$LOOP_DIR/activity.md

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

# Use project settings if they exist (merge base + local if both present)
SETTINGS_ARG=""
if [[ -f ".claude/settings.json" && -f ".claude/settings.local.json" ]]; then
  # Merge: settings.json as base, settings.local.json overrides
  if command -v jq &>/dev/null; then
    MERGED_SETTINGS_FILE="$LOOP_DIR/.merged-settings.json"
    if ! jq -s '.[0] * .[1]' .claude/settings.json .claude/settings.local.json > "$MERGED_SETTINGS_FILE"; then
      echo "Error: Failed to merge settings files. Check JSON syntax in .claude/*.json" >&2
      exit 1
    fi
    SETTINGS_ARG="--settings $MERGED_SETTINGS_FILE"
  else
    # Fallback if jq not available: use base settings (local overrides won't apply)
    echo "Warning: jq not installed. Using settings.json only (local overrides ignored)." >&2
    SETTINGS_ARG="--settings .claude/settings.json"
  fi
elif [[ -f ".claude/settings.local.json" ]]; then
  SETTINGS_ARG="--settings .claude/settings.local.json"
elif [[ -f ".claude/settings.json" ]]; then
  SETTINGS_ARG="--settings .claude/settings.json"
fi

for ((i=1; i<=MAX; i++)); do
  echo "--- Iteration $i / $MAX ---"

  if [[ ! -f "$PROMPT_FILE" ]]; then
    echo "Error: $PROMPT_FILE not found. Was it deleted?" >&2
    exit 1
  fi

  # shellcheck disable=SC2086
  if result=$(claude -p $SETTINGS_ARG "$(cat "$PROMPT_FILE")"); then
    echo "$result"
  else
    exit_code=$?
    echo "Error (exit code $exit_code): claude command failed" >&2
    echo "$result"
    continue
  fi

  if [[ "$result" == *"<promise>COMPLETE</promise>"* ]]; then
    echo "Done after $i iteration(s)."
    exit 0
  fi
done

echo "Reached $MAX iterations without completion. Files in: $LOOP_DIR/"
