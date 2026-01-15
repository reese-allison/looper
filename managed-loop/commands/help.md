---
description: "Explain managed loop commands and options"
---

# Managed Loop Plugin Help

Please explain the following to the user:

## What is a Managed Loop?

A managed loop is an iterative development methodology where the same prompt is fed to Claude repeatedly, allowing incremental progress on complex tasks. Each iteration sees the previous work in files, enabling self-correction and refinement.

**Each iteration:**
1. Claude receives the SAME prompt
2. Works on the task, modifying files
3. Tries to exit
4. Stop hook intercepts and feeds the same prompt again
5. Claude sees its previous work in files
6. Iterates until completion criteria met

## Available Commands

### /loop <PROMPT> [OPTIONS]

Start a managed loop in your current session.

**Usage:**
```
/loop "Build a REST API" --max-iterations 20
/loop --task-mode --git --max-iterations 30
```

**Options:**
- `--max-iterations <n>` - Max iterations before auto-stop (default: 15)
- `--completion-promise <text>` - Promise phrase to signal completion
- `--git` - Enable git commit reminders (disabled by default)
- `--verify` - Enable verification reminders (disabled by default)
- `--task-mode` - Work through plan.md tasks one at a time

---

### /setup-loop [OPTIONS]

Initialize project with plan.md and activity.md for structured loops.

**Usage:**
```
/setup-loop
/setup-loop --force
```

**Options:**
- `--force` - Overwrite existing plan.md and activity.md

**Creates:**
- `plan.md` - JSON-based task tracking with completion criteria
- `activity.md` - Session log for tracking progress

---

### /cancel-loop

Cancel an active managed loop.

**Usage:**
```
/cancel-loop
```

**How it works:**
- Checks for active loop state file
- Removes `.claude/loop-state.local.md`
- Reports cancellation with iteration count

---

## Configurable Features

### Git Integration (--git)

When enabled, reminds you to commit after completing tasks. Useful for:
- Checkpointing progress
- Easy rollback if something goes wrong
- Tracking what changed each iteration

### Verification (--verify)

When enabled, reminds you to verify work with screenshots or tests. Useful for:
- UI development
- Visual confirmation of changes
- Integration with Playwright or similar tools

### Task Mode (--task-mode)

Works through tasks defined in plan.md one at a time. Requires running `/setup-loop` first.

**Workflow:**
1. Run `/setup-loop` to create plan.md and activity.md
2. Edit plan.md to define your tasks
3. Run `/loop --task-mode`
4. Loop works on one task per iteration
5. Updates activity.md with progress
6. Marks tasks complete when success_criteria met

---

## Completion Promises

To signal completion, output a `<promise>` tag:

```
<promise>TASK COMPLETE</promise>
```

The stop hook looks for this specific tag. Without it (or `--max-iterations`), the loop continues.

**Important:** Only output the promise when the statement is genuinely TRUE.

---

## When to Use Managed Loops

**Good for:**
- Well-defined tasks with clear success criteria
- Tasks requiring iteration and refinement
- Iterative development with self-correction
- Projects where you can define completion criteria

**Not ideal for:**
- Tasks requiring human judgment mid-process
- One-shot operations
- Tasks with unclear success criteria
- Debugging that requires real-time interaction
