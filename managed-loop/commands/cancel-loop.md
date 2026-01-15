---
description: "Cancel active managed loop"
allowed-tools: ["Bash(test -f .claude/loop-state.local.md:*)", "Bash(rm .claude/loop-state.local.md)", "Read(.claude/loop-state.local.md)"]
hide-from-slash-command-tool: "true"
---

# Cancel Loop

To cancel the managed loop:

1. Check if `.claude/loop-state.local.md` exists using Bash: `test -f .claude/loop-state.local.md && echo "EXISTS" || echo "NOT_FOUND"`

2. **If NOT_FOUND**: Say "No active loop found."

3. **If EXISTS**:
   - Read `.claude/loop-state.local.md` to get the current iteration number from the `iteration:` field
   - Remove the file using Bash: `rm .claude/loop-state.local.md`
   - Report: "Cancelled loop at iteration N" where N is the iteration value
