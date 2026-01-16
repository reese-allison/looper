# Managed Loop

Run Claude in a loop with fresh context per iteration.

Based on [Ralph Wiggum](https://github.com/JeredBlu/guides/blob/main/Ralph_Wiggum_Guide.md) and [Anthropic's context engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents).

## Usage

```bash
/loop "Review the auth code and fix security issues"
```

Or just `/loop` to be prompted for task.

Sessions are timestamped (`0116-143022`). Resume with `/loop 0116-143022`.

## How it works

1. Creates session in `.looper/0116-143022/`
2. Each iteration spawns fresh `claude -p` (no context bloat)
3. Claude reads `@plan.md`, does task, logs to `activity.md`
4. Exits on `<promise>COMPLETE</promise>` or max iterations

## Permissions

For autonomous operation, add to `.claude/settings.local.json`:

```json
{
  "permissions": {
    "allow": ["Read", "Write", "Edit", "Glob", "Grep", "Bash(git *)"],
    "deny": ["Bash(rm -rf *)", "Bash(sudo *)"]
  }
}
```

## Environment

```bash
LOOPER_DIR=.looper   # Session directory
LOOPER_MAX=10        # Default max iterations
```
