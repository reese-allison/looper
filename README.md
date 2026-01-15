# Looper

Run Claude in a loop with fresh context per iteration.

## Usage

```bash
/loop 20
```

First run creates files in `/tmp`. Edit `plan.md`, run again.

## Installation

```bash
/plugin marketplace add reese-allison/looper
/plugin install managed-loop@reese-allison-looper
```

Or clone directly:
```bash
git clone https://github.com/reese-allison/looper.git
./looper/managed-loop/scripts/loop.sh 20
```

## How it works

`/loop` triggers a bash script that spawns fresh `claude -p` each iteration. No context bloat.

Based on [Ralph Wiggum](https://github.com/JeredBlu/guides/blob/main/Ralph_Wiggum_Guide.md) and [Anthropic's context engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents).
