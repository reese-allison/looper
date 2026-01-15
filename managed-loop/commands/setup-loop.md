---
description: "Initialize project with plan.md and activity.md for managed loops"
argument-hint: "[--force]"
allowed-tools: ["Bash(${CLAUDE_PLUGIN_ROOT}/scripts/setup-project.sh:*)"]
hide-from-slash-command-tool: "true"
---

# Setup Loop Command

Execute the setup script to initialize project structure:

```!
"${CLAUDE_PLUGIN_ROOT}/scripts/setup-project.sh" $ARGUMENTS
```

This creates:
- **plan.md** - Define tasks with JSON structure and completion criteria
- **activity.md** - Track progress across loop iterations

After setup, edit plan.md to define your tasks, then run `/loop --task-mode` to work through them.
