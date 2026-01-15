#!/bin/bash

# Managed Loop - Project Setup Script
# Creates plan.md and activity.md for structured iterative loops

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"

# Parse arguments
FORCE=false
while [[ $# -gt 0 ]]; do
  case $1 in
    -f|--force)
      FORCE=true
      shift
      ;;
    -h|--help)
      cat << 'HELP_EOF'
Managed Loop - Project Setup

USAGE:
  /setup-loop [OPTIONS]

OPTIONS:
  -f, --force    Overwrite existing plan.md and activity.md
  -h, --help     Show this help message

DESCRIPTION:
  Initializes your project for managed loops by creating:
  - plan.md: Task tracking with JSON-based tasks and completion criteria
  - activity.md: Session log for tracking progress across iterations

  These files help maintain context across iterations and enable
  task-based completion (one task per iteration).

AFTER SETUP:
  1. Edit plan.md to define your tasks
  2. Run /loop to start the managed loop
HELP_EOF
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      echo "Use --help for usage information" >&2
      exit 1
      ;;
  esac
done

# Check for existing files
if [[ -f "plan.md" ]] && [[ "$FORCE" != "true" ]]; then
  echo "plan.md already exists. Use --force to overwrite." >&2
  exit 1
fi

if [[ -f "activity.md" ]] && [[ "$FORCE" != "true" ]]; then
  echo "activity.md already exists. Use --force to overwrite." >&2
  exit 1
fi

# Copy templates
cp "$PLUGIN_ROOT/templates/plan.md.template" "plan.md"
cp "$PLUGIN_ROOT/templates/activity.md.template" "activity.md"

# Update activity.md with current timestamp
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
if [[ "$(uname)" == "Darwin" ]]; then
  sed -i '' "s/(timestamp)/$TIMESTAMP/g" "activity.md"
else
  sed -i "s/(timestamp)/$TIMESTAMP/g" "activity.md"
fi

cat << EOF
Managed loop project initialized!

Created files:
  - plan.md: Define your tasks here (edit the JSON array)
  - activity.md: Progress log (updated automatically during loops)

Next steps:
  1. Edit plan.md to define your project tasks
  2. Each task needs: id, category, description, steps, success_criteria
  3. Run: /loop "Your task description" --max-iterations 15

Example plan.md task:
{
  "id": 1,
  "category": "feature",
  "description": "Implement user authentication",
  "steps": [
    "Create login endpoint",
    "Add JWT token generation",
    "Write tests"
  ],
  "success_criteria": "All auth tests pass and login works",
  "passes": false
}
EOF
