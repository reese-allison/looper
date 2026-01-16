---
description: "Run a loop with fresh context per iteration"
argument-hint: '"task" or session-name'
allowed-tools: ["Bash"]
---

# Loop

```!
"${CLAUDE_PLUGIN_ROOT}/scripts/loop.sh" $ARGUMENTS
```

**Usage:** `/loop "Review the auth code"` or `/loop` (prompts)

**Resume:** `/loop 0116-143022` (session name from output)
