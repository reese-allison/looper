---
description: "Show loop help"
---

# Managed Loop

```bash
./managed-loop/scripts/loop.sh 20              # New session (timestamp name)
./managed-loop/scripts/loop.sh 20 my-session   # Named session
```

First run creates files in `.looper/<session>/`.
Edit `plan.md` with your tasks, then run again with the same session name.

Custom location: `LOOPER_DIR=~/.myloop ./managed-loop/scripts/loop.sh 20`

**Permissions**: Configure `.claude/settings.local.json` with `allow`/`deny` lists for autonomous operation. See README.
