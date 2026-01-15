#!/bin/bash

# Managed Loop Setup Script
# Creates state file for in-session managed loop with configurable options

set -euo pipefail

# Parse arguments
PROMPT_PARTS=()
MAX_ITERATIONS=15
COMPLETION_PROMISE="null"
GIT_ENABLED=false
VERIFY_ENABLED=false
TASK_MODE=false

# Parse options and positional arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      cat << 'HELP_EOF'
Managed Loop - Interactive iterative development loop

USAGE:
  /loop [PROMPT...] [OPTIONS]

ARGUMENTS:
  PROMPT...    Initial prompt/task description (can be multiple words)

OPTIONS:
  --max-iterations <n>           Maximum iterations before auto-stop (default: 15)
  --completion-promise '<text>'  Promise phrase that signals completion (USE QUOTES for multi-word)
  --git                          Enable git commits after each completed task
  --no-git                       Disable git commits (default)
  --verify                       Enable verification reminders (Playwright/screenshots)
  --no-verify                    Disable verification reminders (default)
  --task-mode                    Work from plan.md tasks (one task per iteration)
  -h, --help                     Show this help message

DESCRIPTION:
  Starts a managed loop in your CURRENT session. The stop hook prevents
  exit and feeds your prompt back as input until completion or iteration limit.

  To signal completion, output: <promise>YOUR_PHRASE</promise>

EXAMPLES:
  /loop Build a todo API --completion-promise 'DONE' --max-iterations 20
  /loop --task-mode --git --max-iterations 30
  /loop Fix the auth bug --verify
  /loop Refactor cache layer --completion-promise 'COMPLETE'

STOPPING:
  - Reaching --max-iterations (default: 15)
  - Outputting the --completion-promise phrase
  - Running /cancel-loop

CONFIGURABLE FEATURES:
  Git Integration (--git):
    When enabled, prompts you to commit after each completed task.
    Useful for checkpointing progress.

  Verification (--verify):
    When enabled, reminds you to verify work with screenshots/Playwright.
    Useful for UI work or when you need visual confirmation.

  Task Mode (--task-mode):
    Works through tasks defined in plan.md one at a time.
    Requires plan.md to exist (run /setup-loop first).

MONITORING:
  # View current iteration:
  grep '^iteration:' .claude/loop-state.local.md

  # View full state:
  head -15 .claude/loop-state.local.md
HELP_EOF
      exit 0
      ;;
    --max-iterations)
      if [[ -z "${2:-}" ]]; then
        echo "Error: --max-iterations requires a number argument" >&2
        exit 1
      fi
      if ! [[ "$2" =~ ^[0-9]+$ ]]; then
        echo "Error: --max-iterations must be a positive integer, got: $2" >&2
        exit 1
      fi
      MAX_ITERATIONS="$2"
      shift 2
      ;;
    --completion-promise)
      if [[ -z "${2:-}" ]]; then
        echo "Error: --completion-promise requires a text argument" >&2
        exit 1
      fi
      COMPLETION_PROMISE="$2"
      shift 2
      ;;
    --git)
      GIT_ENABLED=true
      shift
      ;;
    --no-git)
      GIT_ENABLED=false
      shift
      ;;
    --verify)
      VERIFY_ENABLED=true
      shift
      ;;
    --no-verify)
      VERIFY_ENABLED=false
      shift
      ;;
    --task-mode)
      TASK_MODE=true
      shift
      ;;
    *)
      # Non-option argument - collect as prompt parts
      PROMPT_PARTS+=("$1")
      shift
      ;;
  esac
done

# Join all prompt parts with spaces
PROMPT="${PROMPT_PARTS[*]:-}"

# Validate: need either prompt or task-mode
if [[ -z "$PROMPT" ]] && [[ "$TASK_MODE" != "true" ]]; then
  echo "Error: No prompt provided" >&2
  echo "" >&2
  echo "   Provide a task description or use --task-mode with plan.md" >&2
  echo "" >&2
  echo "   Examples:" >&2
  echo "     /loop Build a REST API for todos" >&2
  echo "     /loop --task-mode --max-iterations 20" >&2
  echo "" >&2
  echo "   For all options: /loop --help" >&2
  exit 1
fi

# If task-mode, check for plan.md
if [[ "$TASK_MODE" == "true" ]] && [[ ! -f "plan.md" ]]; then
  echo "Error: --task-mode requires plan.md to exist" >&2
  echo "" >&2
  echo "   Run /setup-loop first to create plan.md and activity.md" >&2
  exit 1
fi

# Create state file directory
mkdir -p .claude

# Quote completion promise for YAML if it contains special chars or is not null
if [[ -n "$COMPLETION_PROMISE" ]] && [[ "$COMPLETION_PROMISE" != "null" ]]; then
  COMPLETION_PROMISE_YAML="\"$COMPLETION_PROMISE\""
else
  COMPLETION_PROMISE_YAML="null"
fi

# Build the prompt content
if [[ "$TASK_MODE" == "true" ]]; then
  if [[ -n "$PROMPT" ]]; then
    FULL_PROMPT="@plan.md @activity.md

$PROMPT

Work on the next incomplete task from plan.md (where passes is false).
Update activity.md with your progress.
When the task's success_criteria is met, set passes to true in plan.md."
  else
    FULL_PROMPT="@plan.md @activity.md

Work on the next incomplete task from plan.md (where passes is false).
Update activity.md with your progress.
When the task's success_criteria is met, set passes to true in plan.md."
  fi
else
  FULL_PROMPT="$PROMPT"
fi

# Create state file (markdown with YAML frontmatter)
cat > .claude/loop-state.local.md <<EOF
---
active: true
iteration: 1
max_iterations: $MAX_ITERATIONS
completion_promise: $COMPLETION_PROMISE_YAML
git_enabled: $GIT_ENABLED
verify_enabled: $VERIFY_ENABLED
task_mode: $TASK_MODE
started_at: "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
---

$FULL_PROMPT
EOF

# Output setup message
cat <<EOF
Managed loop activated!

Configuration:
  Iteration: 1 / $(if [[ $MAX_ITERATIONS -gt 0 ]]; then echo $MAX_ITERATIONS; else echo "unlimited"; fi)
  Completion: $(if [[ "$COMPLETION_PROMISE" != "null" ]]; then echo "<promise>$COMPLETION_PROMISE</promise>"; else echo "none set"; fi)
  Git commits: $(if [[ "$GIT_ENABLED" == "true" ]]; then echo "enabled"; else echo "disabled"; fi)
  Verification: $(if [[ "$VERIFY_ENABLED" == "true" ]]; then echo "enabled"; else echo "disabled"; fi)
  Task mode: $(if [[ "$TASK_MODE" == "true" ]]; then echo "enabled (using plan.md)"; else echo "disabled"; fi)

The stop hook is now active. When you try to exit, your prompt will be
fed back to continue the loop. Your previous work persists in files.

To cancel: /cancel-loop
To monitor: head -15 .claude/loop-state.local.md

EOF

# Output the prompt
echo "$FULL_PROMPT"

# Display completion promise requirements if set
if [[ "$COMPLETION_PROMISE" != "null" ]]; then
  echo ""
  echo "════════════════════════════════════════════════════════════"
  echo "COMPLETION REQUIREMENT"
  echo "════════════════════════════════════════════════════════════"
  echo ""
  echo "To complete this loop, output this EXACT text:"
  echo "  <promise>$COMPLETION_PROMISE</promise>"
  echo ""
  echo "Only output this when the statement is genuinely TRUE."
  echo "════════════════════════════════════════════════════════════"
fi

# Git reminder if enabled
if [[ "$GIT_ENABLED" == "true" ]]; then
  echo ""
  echo "Git integration enabled - commit your work after completing tasks."
fi

# Verify reminder if enabled
if [[ "$VERIFY_ENABLED" == "true" ]]; then
  echo ""
  echo "Verification enabled - use screenshots/Playwright to verify your work."
fi
