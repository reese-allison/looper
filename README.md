# Looper

Claude Code plugin marketplace for development loops.

## Installation

```bash
# 1. Add the marketplace
/plugin marketplace add YOUR_USERNAME/looper

# 2. Install the plugin
/plugin install managed-loop@YOUR_USERNAME-looper
```

Replace `YOUR_USERNAME` with your GitHub username (e.g., `reeseallison/looper`).

## Available Plugins

| Plugin | Description |
|--------|-------------|
| [managed-loop](./managed-loop) | Run Claude in a loop with fresh context per iteration |

## Why Looper?

- **Minimal**: 132 lines of bash
- **Fresh context**: Each iteration starts clean (no bloat)
- **Best practices**: Based on Anthropic's context engineering guide

Based on [Ralph Wiggum Guide](https://github.com/JeredBlu/guides/blob/main/Ralph_Wiggum_Guide.md) and [Anthropic's Context Engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents).
