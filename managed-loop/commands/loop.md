---
description: "Start a managed loop in current session"
argument-hint: "PROMPT [--max-iterations N] [--completion-promise TEXT] [--git] [--verify] [--task-mode]"
allowed-tools: ["Bash(${CLAUDE_PLUGIN_ROOT}/scripts/setup-loop.sh:*)"]
hide-from-slash-command-tool: "true"
---

# Managed Loop Command

Execute the setup script to initialize the managed loop:

```!
"${CLAUDE_PLUGIN_ROOT}/scripts/setup-loop.sh" $ARGUMENTS
```

Work on the task. When you try to exit, the loop will feed the SAME PROMPT back to you for the next iteration. Your previous work persists in files, allowing you to iterate and improve.

## Options

- `--max-iterations N` - Stop after N iterations (default: 15)
- `--completion-promise TEXT` - Phrase that signals completion
- `--git` - Enable git commit reminders after tasks
- `--verify` - Enable verification reminders (screenshots/tests)
- `--task-mode` - Work through tasks in plan.md one at a time

## Completion Rule

If a completion promise is set, you may ONLY output it when the statement is completely and unequivocally TRUE. Do not output false promises to escape the loop.
