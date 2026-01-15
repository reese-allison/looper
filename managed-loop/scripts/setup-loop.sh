#!/bin/bash

# Setup loop state for plugin mode
# Usage: Called by /loop command

set -euo pipefail

MAX_ITERATIONS="${1:-10}"
shift || true
PROMPT="$*"

[[ -z "$PROMPT" ]] && echo "Usage: /loop <prompt> [max-iterations]" && exit 1

mkdir -p .claude

cat > .claude/loop-state.local.md << EOF
---
iteration: 1
max: $MAX_ITERATIONS
---

$PROMPT

When done, output <promise>COMPLETE</promise>
EOF

echo "Loop: $MAX_ITERATIONS iterations"
echo ""
echo "$PROMPT"
