# Managed Loop Plugin

Task-based iterative loops with structured planning, configurable git integration, and optional verification support for Claude Code.

## Overview

Managed loops allow Claude to work iteratively on complex tasks. The same prompt is fed back after each attempt to exit, enabling self-correction and incremental progress. Your previous work persists in files, creating a feedback loop where Claude builds on its own output.

## Key Features

- **Task-based iterations** - Work on one task at a time from plan.md
- **Structured planning** - plan.md and activity.md for tracking progress
- **Configurable git integration** - Optional commits after tasks (disabled by default)
- **Optional verification** - Reminders to verify work with screenshots/tests
- **Sensible defaults** - Max 15 iterations by default (not unlimited)
- **Clear completion criteria** - Promise-based completion signals

## Installation

Copy this plugin to your Claude Code plugins directory:

```bash
cp -r managed-loop ~/.claude/plugins/local/managed-loop
```

Or install from the plugin marketplace if available.

## Quick Start

### Basic Usage

```bash
# Simple loop with default settings
/loop "Build a REST API for todos" --completion-promise "DONE"

# Loop with iteration limit
/loop "Fix the auth bug" --max-iterations 10

# Loop with git commits enabled
/loop "Refactor the cache layer" --git --max-iterations 20
```

### Task Mode (Recommended for Complex Projects)

```bash
# 1. Initialize project structure
/setup-loop

# 2. Edit plan.md to define your tasks
# 3. Start the loop in task mode
/loop --task-mode --max-iterations 30 --completion-promise "ALL TASKS COMPLETE"
```

## Commands

### `/loop [PROMPT] [OPTIONS]`

Start a managed loop.

**Options:**
| Option | Default | Description |
|--------|---------|-------------|
| `--max-iterations N` | 15 | Stop after N iterations |
| `--completion-promise TEXT` | none | Phrase that signals completion |
| `--git` | disabled | Enable git commit reminders |
| `--verify` | disabled | Enable verification reminders |
| `--task-mode` | disabled | Work through plan.md tasks |

### `/setup-loop [OPTIONS]`

Initialize project with plan.md and activity.md.

**Options:**
| Option | Description |
|--------|-------------|
| `--force` | Overwrite existing files |

### `/cancel-loop`

Cancel an active loop.

### `/help`

Show detailed help for all commands.

## Structured Planning

### plan.md

Define tasks with JSON structure:

```json
[
  {
    "id": 1,
    "category": "feature",
    "description": "Implement user authentication",
    "steps": [
      "Create login endpoint",
      "Add JWT token generation",
      "Write tests"
    ],
    "success_criteria": "All auth tests pass",
    "passes": false
  }
]
```

### activity.md

Tracks progress across iterations:

```markdown
## Current State
- **Last Updated**: 2024-01-15T10:30:00Z
- **Current Task ID**: 1
- **Iteration**: 3
- **Status**: In progress

## Session Log
### Iteration 3
**Task**: Implement user authentication
**Actions Taken**:
- Created login endpoint
- Added JWT generation

**Result**: Tests failing on token validation
**Next Steps**: Fix token validation logic
```

## Configurable Features

### Git Integration (`--git`)

When enabled, reminds Claude to commit after completing tasks. Useful for:
- Checkpointing progress
- Easy rollback if something goes wrong
- Tracking changes per iteration

### Verification (`--verify`)

When enabled, reminds Claude to verify work. Useful for:
- UI development (take screenshots)
- Integration with Playwright
- Visual confirmation of changes

Both features are **disabled by default** - enable only when needed.

## Completion Signals

To end a loop, Claude must output the completion promise:

```
<promise>YOUR_COMPLETION_TEXT</promise>
```

This only works when `--completion-promise` is set. The loop also ends when `--max-iterations` is reached.

## Best Practices

1. **Set max iterations** - Always use `--max-iterations` as a safety net
2. **Define clear tasks** - Each task should have specific success criteria
3. **Use task mode** - For complex projects, use plan.md for structure
4. **Start small** - Begin with 10-15 iterations and adjust as needed
5. **Review activity.md** - Check progress between sessions

## File Structure

```
managed-loop/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   ├── loop.md
│   ├── setup-loop.md
│   ├── cancel-loop.md
│   └── help.md
├── hooks/
│   ├── hooks.json
│   └── stop-hook.sh
├── scripts/
│   ├── setup-loop.sh
│   └── setup-project.sh
├── templates/
│   ├── plan.md.template
│   ├── activity.md.template
│   └── PROMPT.md.template
└── README.md
```

## Troubleshooting

### Loop won't stop
- Check if `--max-iterations` is set
- Verify the completion promise matches exactly
- Run `/cancel-loop` to force stop

### Task mode not working
- Run `/setup-loop` first to create plan.md
- Ensure plan.md has valid JSON structure
- Check that at least one task has `"passes": false`

### State file corrupted
- Delete `.claude/loop-state.local.md`
- Start fresh with `/loop`

## License

MIT
