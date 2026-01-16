---
description: 'Run a loop with fresh context per iteration. Args: just pass the task string like "Review the code" - no key=value pairs'
argument-hint: '"your task description here"'
allowed-tools: ["Bash"]
---

# Loop

```!
"${CLAUDE_PLUGIN_ROOT}/scripts/loop.sh" $ARGUMENTS
```

**Argument format**: Pass ONLY the task as a quoted string. No key=value pairs.

✓ Correct: `/loop "Review the auth code"`
✓ Correct: `/loop "Fix all type errors in src/"`
✓ Correct: `/loop 0116-143022` (resume session)
✗ Wrong: `/loop iterations=5 task="..."`
✗ Wrong: `/loop --task "..." --max 5`
