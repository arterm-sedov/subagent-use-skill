#!/usr/bin/env bash
# Create a new subagent-use plan

set -euo pipefail

PLANS_DIR=".plans"
PROGRESS_DIR=".plans/progress"

usage() {
    cat <<EOF
Usage: $0 <plan-name> [goal]
Creates a new plan file with checklist template.

Usage: $0 feature-x "Add feature X with tests"
EOF
}

if [[ $# -lt 1 ]]; then
    usage
    exit 1
fi

NAME="$1"
GOAL="${2:-}"

mkdir -p .plans .plans/progress

NN=$(printf "%02d" $(ls .plans/*.md 2>/dev/null | wc -l + 1))
NAME="${NN}-${NAME// /-}"

FILE=".plans/${NAME}.md"

cat > ".plans/${NAME}.md" <<EOF
# Plan: ${NAME}

## Goal
${GOAL:-TODO: Describe measurable objective}

## Prerequisites
- [ ] Pre-req 1
- [ ] Pre-req 2

## Phases

### Phase 1: [Name]
- [ ] Step 1
- [ ] Step 2

### Phase 2: [Name]
- [ ] Step 1
- [ ] Step 2

## Affected Files
| File | Change |
|------|--------|

## Verification
- [ ] Test 1
- [ ] Test 2

## Dependencies
- Depends on: ...
- Blocks: ...
EOF

echo "Created ${FILE}"
echo "Progress file: .plans/progress/$(printf "%02d" ${NN})-$(echo ${NAME} | cut -d- -f2- | sed 's/^[0-9]*-//')"