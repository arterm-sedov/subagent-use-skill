# Subagent Use Skill

**Name:** subagent-use  
**Version:** 1.0.0  
**Description:** Reusable skill for managing subagent workflows with progress tracking, plans, and deep research

## When to Use
- Any task requiring subagent delegation
- Research tasks requiring deep investigation
- Multi-step migrations/validations
- File reorganization tasks

## Patterns

### Pattern 1: Research Subagent
**When:** Need external facts, standards comparison, best practices
**Prompt:** `Research [topic] with questions: Q1, Q2. Sources: [list]. Output to .research/[topic].md`
**Output:** Structured markdown with citations, saved to `.research/[topic]-research.md`

### Pattern 2: Execution Subagent
**When:** Multi-step plan execution
**Prompt:** `Execute steps 1-5 from .plans/04-plan.md. Save progress to .plans/progress/04-migration.md after each step.`
**Progress:** Subagent writes to `.plans/progress/XX-name.md` after each step

### Pattern 2: Validation Subagent
**When:** Need to verify outputs
**Prompt:** `Validate all examples with --cyclonedx flag. Save results to .plans/progress/validation.md`
**Output:** Validation results saved to progress file

### Pattern 4: Planning Subagent
**When:** Need detailed plan from high-level goal
**Prompt:** `Create detailed plan for [goal]. Output to .plans/NN-name.md with checklist.`
**Output:** Detailed plan file with checklist

---

## Rules (Enforced)

1. **Main never writes code** when subagent can do it
2. **Subagent never commits** - only Main commits
3. **Progress file mandatory** for tasks > 30 min
4. **Atomic tasks** - one logical change = one subagent
5. **Validate every step** - validator runs after each change
6. **No silent failures** - errors = immediate escalation
5. **Progress file** updated after EVERY step

---

## Quick Reference

```bash
# Create plan
./scripts/create-plan.sh feature-x "Add feature X"

# Track progress
./scripts/create-progress.sh feature-x

# Research
./scripts/launch-subagent.sh research "CycloneDX naming" "Is YAML valid?"

# Execute plan
./scripts/launch-subagent.sh execute .plans/01-feature-x.md

# Validate
./scripts/launch-subagent.sh validate --json file.json --md file.md --cyclonedx

# Check progress
cat .plans/progress/01-feature-x.md
```

## Directory Structure

```
.repo/
├── .plans/
│   ├── NN-plan-name.md
│   └── progress/
│       └── NN-plan-name.md
├── .research/
│   └── topic-research.md
├── .agents/skills/subagent-use/
│   ├── SKILL.md
│   ├── templates/
│   │   ├── plan-template.md
│   │   ├── progress.md
│   │   ├── research-output.md
│   │   └── subagent-prompt.md
│   └── scripts/
│       ├── create-plan.sh
│       ├── create-progress.sh
│       └── launch-subagent.sh
└── README.md
```

## Key Rules

| Rule | Enforcement |
|------|-------------|
| Main never writes code | Delegate to subagent |
| Subagent never commits | Main commits only |
| Progress file required | Tasks > 30 min |
| Atomic commits | One logical change = one commit |
| Validate every step | Validator runs after each change |
| English in code/commits | Team readability |