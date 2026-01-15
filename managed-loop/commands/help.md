---
description: "Show loop help"
---

# Managed Loop

Run Claude in a loop with fresh context per iteration.

## Bash (Recommended)

```bash
./managed-loop/scripts/loop.sh 20
```

Reads `PROMPT.md` and runs until `<promise>COMPLETE</promise>` or max iterations.

## Plugin Mode

```bash
/loop "Your task" 10
```

Single context window. Use bash for longer tasks.

## Files

- `PROMPT.md` - Instructions (includes @plan.md @activity.md)
- `plan.md` - Tasks with `passes` flags
- `activity.md` - Progress log

## Setup

```bash
cp templates/PROMPT.md.template PROMPT.md
cp templates/plan.md.template plan.md
cp templates/activity.md.template activity.md
# Edit plan.md with your tasks
./managed-loop/scripts/loop.sh 20
```
