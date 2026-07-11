#!/usr/bin/env bash
# Launch a subagent with proper context

set -euo pipefail

usage() {
    cat <<EOF
Usage: $0 <type> <plan-file> [extra-context]

Types:
  research  - Deep research with web searches
  execute   - Execute plan steps
  validate  - Run validation checks
  plan      - Create detailed plan from high-level goal

Usage:
  $0 research "topic" "questions.txt"
  $0 execute .plans/04-plan.md
  $0 validate --json file.json --md file.md

Environment:
  REPO_ROOT - repo root (default: pwd)
  PROGRESS_DIR - progress dir (default: .plans/progress)
EOF
}

if [[ $# -lt 2 ]]; then
    usage
    exit 1
fi

TYPE="$1"
PLAN="$2"
shift 2
EXTRA="${1:-}"

REPO_ROOT="${REPO_ROOT:-$(pwd)}"
PROGRESS_DIR="${PROGRESS_DIR:-.plans/progress}"

case "$TYPE" in
    research)
        TOPIC="${PLAN}"
        shift
        # Launch research subagent
        cat <<EOF
# Research Subagent Launch

**Topic:** ${TOPIC}
**Questions:** $@
**Output:** .research/\${TOPIC}-research.md

Run with: Task tool, subagent_type=explore
EOF
        ;;
    execute)
        PLAN_FILE="$2"
        if [[ ! -f "$PLAN_FILE" ]]; then
            echo "Plan file not found: $PLAN_FILE" >&2
            exit 1
        fi
        echo "Executing plan: $PLAN_FILE"
        echo "Progress: .plans/progress/$(basename "$PLAN_FILE" .md).md"
        ;;
    validate)
        shift
        # Run validator
        python3 .agents/skills/delivery-registry-manifest-builder/scripts/validate_delivery_manifest.py "$@"
        ;;
    plan)
        # Create detailed plan from high-level goal
        GOAL="$2"
        # Implementation: Task tool → explore agent
        echo "Creating detailed plan for: $GOAL"
        ;;
    *)
        echo "Unknown type: $TYPE" >&2
        exit 1
        ;;
esac