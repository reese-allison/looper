---
description: "Cancel active managed loop"
allowed-tools: ["Bash(rm -f .claude/loop-state.local.md)"]
hide-from-slash-command-tool: "true"
---

# Cancel Loop

Remove the loop state file:

```!
rm -f .claude/loop-state.local.md && echo "Loop cancelled" || echo "No active loop"
```
