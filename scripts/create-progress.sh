#!/usr/bin/env bash
# Create progress file for a plan

set -euo pipefail

usage() {
    cat <<EOF
Usage: $0 <plan-name> [status]
Creates/updates progress file for a plan.

Usage: $0 plan-name IN_PROGRESS
EOF
}

if [[ $# -lt 1 ]]; then
    usage
    exit 1
fi

PLAN_NAME="$1"
STATUS="${2:-IN_PROGRESS}"

PROGRESS_DIR=".plans/progress"
mkdir -p .plans/progress

# Find plan number from plan file
PLAN_FILE=$(ls .plans/*"${PLAN_NAME}"* 2>/dev/null | head -1)
if [[ -z "$PLAN_FILE" ]]; then
    echo "Plan not found: $PLAN_NAME" >&2
    exit 1
fi

# Extract plan number (NN from NN-name.md)
BASENAME=$(basename "$PLAN_FILE" .md)
NN="${BASENAME%%-*}"
PROGRESS_FILE=".plans/progress/${NN}-$(basename "${PLAN_NAME}")"

cat > ".plans/progress/${NN}-$(basename "${PLAN_NAME}")" <<EOF
# Progress: ${PLAN_NAME}

## Status: IN_PROGRESS

## Completed
- [ ] Step 1
- [ ] Step 2

## Current
- [ ] Step 1: 

## Blockers
- None

## Next
- Step 1: 
EOF

echo "Created .plans/progress/$(basename "$PROGRESS_FILE")"