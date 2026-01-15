# Managed Loop

Run Claude in a loop with fresh context per iteration.

Based on [Ralph Wiggum](https://github.com/JeredBlu/guides/blob/main/Ralph_Wiggum_Guide.md) and [Anthropic's context engineering guide](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents).

## Features

| Feature | Description |
|---------|-------------|
| Fresh context | Each iteration starts clean - no bloat |
| Minimal | 132 lines total |
| Error recovery | Logs errors and continues |
| Timing | Shows per-iteration and total time |
| Dry run | Preview prompt without API calls |
| Graceful exit | CTRL+C shows summary |

**Philosophy**: Do less. Trust Claude. Keep context fresh.

## Quick Start

```bash
# 1. Create your files
cp templates/PROMPT.md.template PROMPT.md
cp templates/plan.md.template plan.md
cp templates/activity.md.template activity.md

# 2. Edit plan.md with your tasks
# 3. Edit PROMPT.md if needed

# 4. Run
./managed-loop/scripts/loop.sh 20
```

## How It Works

The script runs `claude -p "$(cat PROMPT.md)"` in a loop. Each iteration:
1. Gets fresh context (no bloat)
2. Reads plan.md and activity.md via @ references
3. Works on one task
4. Updates files
5. Repeats until `<promise>COMPLETE</promise>` or max iterations

## Files

| File | Purpose |
|------|---------|
| `PROMPT.md` | Instructions for each iteration |
| `plan.md` | Tasks with `passes` flags |
| `activity.md` | Progress log |

### plan.md format

```json
[
  {
    "id": 1,
    "description": "Your task",
    "passes": false
  }
]
```

### PROMPT.md format

```markdown
@plan.md @activity.md

Read activity.md for current state.
Work on next task where passes is false.
Update activity.md and set passes to true when done.

When ALL tasks complete, output <promise>COMPLETE</promise>
```

## Installation

### From GitHub (Recommended)

```bash
# 1. Add the marketplace
/plugin marketplace add reese-allison/looper

# 2. Install the plugin
/plugin install managed-loop@reese-allison-looper
```

### Manual

```bash
git clone https://github.com/reese-allison/looper.git
ln -sf $(pwd)/looper/managed-loop ~/.claude/plugins/local/managed-loop
```

## Usage

### Bash (Recommended)

```bash
./managed-loop/scripts/loop.sh 20         # Run 20 iterations
./managed-loop/scripts/loop.sh 20 --dry-run  # Preview without running
```

### Plugin Mode (Short tasks only)

```bash
/loop "Fix the login bug" 10
```

Plugin mode runs in a single context window. Use bash for tasks over 10 iterations.

## Why Fresh Context?

From Anthropic's guide:
> "Treat context as a precious, finite resource with diminishing marginal returns."

Single-session loops accumulate context bloat. The bash approach gives each iteration a clean slate by reading state from files.

## Templates

Copy from `templates/` directory:
- `PROMPT.md.template` - Standard task loop prompt
- `plan.md.template` - Task list format
- `activity.md.template` - Progress log format
