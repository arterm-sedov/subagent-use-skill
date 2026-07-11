# Subagent-Use Skill

A reusable skill for managing subagent workflows with progress tracking, plans, and deep research.

## Quick Start

```bash
# 1. Create a plan
./scripts/create-plan.sh feature-x "Add feature X with tests"

# 2. Track progress
./scripts/create-progress.sh feature-x

# 3. Launch subagent to execute
./scripts/launch-subagent.sh execute .plans/01-feature-x.md

# 4. Or research first
./scripts/launch-subagent.sh research "CycloneDX naming" "What is standard?"

# 5. Validate
./scripts/launch-subagent.sh validate --json manifest.cdx.json --md manifest.md --cyclonedx
```

## Structure

```
.opencode/skills/subagent-use/
├── SKILL.md              # This skill manifest
├── templates/
│   ├── plan-template.md
│   ├── progress.md
│   ├── research-output.md
│   └── subagent-prompt.md
├── scripts/
│   ├── create-plan.sh
│   ├── create-progress.sh
│   └── launch-subagent.sh
├── scripts/validate_delivery_manifest.py  (external reference)
└── README.md
```

## Quick Commands

```bash
# Create plan
./scripts/create-plan.sh feature-x "Add feature X"

# Track progress
./scripts/create-progress.sh feature-x

# Launch research
./scripts/launch-subagent.sh research "CycloneDX naming" "Is YAML valid?"

# Execute plan
./scripts/launch-subagent.sh execute .plans/01-feature-x.md

# Validate
./scripts/launch-subagent.sh validate --json file.json --md file.md --cyclonedx
```

## Progress Tracking

```bash
# Check progress
cat .plans/progress/01-feature-x.md

# Update manually or via subagent
sed -i 's/\[ \] Step 1/[x] Step 1/' .plans/progress/01-feature-x.md
```

## Research Workflow

```bash
# Launch deep research
./scripts/launch-subagent.sh research "CycloneDX naming" "Is YAML valid?"

# Output saved to .research/cyclonedx-naming-research.md
```

## Integration with Main Agent

```bash
# Main agent creates plan
./scripts/create-plan.sh migrate-yaml "Migrate YAML to JSON"

# Main agent launches subagent
./scripts/launch-subagent.sh execute .plans/01-migrate-yaml.md

# Subagent writes progress to .plans/progress/
# Main agent reviews, commits, pushes
```