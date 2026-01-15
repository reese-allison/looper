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

| Metric | managed-loop | kettle |
|--------|--------------|--------|
| Lines of code | 132 | 800+ |
| Context approach | Fresh per iteration | Bloating session |
| Dependencies | bash, jq | bash, docker, jq |
| Following best practices | Yes | No |

Based on [Ralph Wiggum Guide](https://github.com/JeredBlu/guides/blob/main/Ralph_Wiggum_Guide.md) and [Anthropic's Context Engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents).
