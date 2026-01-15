---
description: "Run a loop with fresh context per iteration"
argument-hint: "<max-iterations> [loop-dir]"
allowed-tools: ["Bash"]
---

# Loop

Run Claude in a loop with fresh context per iteration.

```!
"${CLAUDE_PLUGIN_ROOT}/scripts/loop.sh" $ARGUMENTS
```

First run creates files in `/tmp/looper-<pid>/`. Edit `plan.md` with your tasks, then run `/loop` again.

Each iteration spawns a new Claude process - no context bloat.
