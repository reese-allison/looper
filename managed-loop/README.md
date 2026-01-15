# Managed Loop

Run Claude in a loop with fresh context per iteration.

Based on [Ralph Wiggum](https://github.com/JeredBlu/guides/blob/main/Ralph_Wiggum_Guide.md) and [Anthropic's context engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents).

## Usage

```bash
/loop 20
```

Or directly:
```bash
./managed-loop/scripts/loop.sh 20
```

First run creates files in `.looper/`. Edit `plan.md` with your tasks, run again.

## How it works

1. `/loop` triggers bash script
2. Bash spawns fresh `claude -p` each iteration
3. Claude reads plan via `@plan.md`, does one task, updates files
4. Repeats until all tasks checked or max iterations

**Fresh context**: Each iteration is a new Claude process. No bloat.

## Permissions

The loop merges `.claude/settings.json` (base) with `.claude/settings.local.json` (overrides) using jq, then passes `--settings` to each iteration. Falls back to base-only if jq unavailable. Configure allow/deny lists there for autonomous operation.

## Custom location

```bash
LOOPER_DIR=~/myproject/.looper ./managed-loop/scripts/loop.sh 20
```
