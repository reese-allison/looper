---
description: "Start a loop (plugin mode - use ./loop.sh for long tasks)"
argument-hint: "<prompt> [max-iterations]"
allowed-tools: ["Bash(${CLAUDE_PLUGIN_ROOT}/scripts/setup-loop.sh:*)"]
---

# Loop

```!
"${CLAUDE_PLUGIN_ROOT}/scripts/setup-loop.sh" $ARGUMENTS
```

Work on the task. Output `<promise>COMPLETE</promise>` when done.

**Note**: For tasks over 10 iterations, use the bash script instead:
```bash
./managed-loop/scripts/loop.sh 30
```
