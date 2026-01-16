---
description: "Show loop help"
---

# Managed Loop

```bash
/loop "Review the auth code"    # New session with task
/loop 5 "Review the auth code"  # With max 5 iterations
/loop                           # Prompts for task
/loop 0116-143022               # Resume existing session
```

Creates files in `.looper/<session>/` (auto-timestamped).
Claude reads `plan.md`, executes tasks, logs to `activity.md`.

**Options:**
- `LOOPER_MAX=20` - Set max iterations (default: 10)
- `LOOPER_DIR=~/.myloop` - Custom session directory

**Permissions**: Configure `.claude/settings.local.json` with `allow`/`deny` lists for autonomous operation. See README.
