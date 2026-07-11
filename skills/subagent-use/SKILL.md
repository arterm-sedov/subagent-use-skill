# Subagent Use Skill (Agent-Native)

**Name:** subagent-use  
**Version:** 2.1.0  
**Description:** Agent-native patterns for managing subagent workflows with progress tracking, plans, and deep research. No shell scripts — use directly via Task tool and file operations.

---

## When to Use

- Any task requiring subagent delegation
- Research tasks requiring deep investigation
- Multi-step migrations/validations
- File reorganization tasks
- Any task > 30 minutes

---

## Core Rules (Enforced)

| Rule | Enforcement |
|------|-------------|
| Main never writes code | Delegate to subagent via Task tool |
| Subagent never commits | Main commits only |
| Progress file mandatory | Tasks > 30 min → create `.plans/progress/XX-name.md` |
| Atomic tasks | One logical change = one subagent |
| Validate every step | Run validator after each change |
| No silent failures | Errors = immediate escalation to Main |
| Progress file updated | After EVERY step (mark `[x]` immediately) |
| Primary artifacts are `.md` | Plans, progress, research → Markdown with checkboxes, tables, headings |

---

## Directory Structure (Auto-Created)

```
.repo/
├── .plans/
│   ├── NN-plan-name.md          # Plan files (auto-numbered)
│   └── progress/
│       └── NN-plan-name.md      # Progress files (match plan number)
├── .research/
│   └── topic-research.md        # Research outputs
└── .agents/skills/subagent-use/
    ├── SKILL.md                 # This file
    └── references/
        ├── templates/           # Plan, progress, research templates
        ├── examples/            # Example files
        └── schemas/             # Validation schemas
```

**Agent creates directories on first use:** `mkdir -p .plans .plans/progress .research`

**Additional files** (data dumps, raw API responses, configs) may use any format — save alongside `.md` artifacts.

---

## Agent Workflows

### 1. Create a Plan

**When:** Starting any multi-step task  
**How (Agent does this directly):**

```python
# 1. Determine next plan number
existing = glob(".plans/*.md")
nn = f"{len(existing) + 1:02d}"

# 2. Create plan file using template structure
plan_name = f"{nn}-{slugify(short_description)}"
plan_path = f".plans/{plan_name}.md"

# 3. Write plan with structure from references/templates/plan-template.md
write(plan_path, f"""# Plan: {plan_name}

## Goal
[Measurable objective - what "done" looks like]

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
""")
```

**Template reference:** `references/templates/plan-template.md` — use this exact structure.

---

### 2. Create Progress File

**When:** Subagent starts executing a plan (or Main delegates execution)  
**How (Agent does this directly):**

```python
# 1. Extract plan number from plan file
#    e.g., ".plans/04-migration.md" → "04"
plan_num = basename(plan_path).split("-")[0]

# 2. Create progress file matching plan number
progress_name = f"{plan_num}-{slugify(task_name)}"
progress_path = f".plans/progress/{progress_name}"

# 3. Write progress using template structure
write(progress_path, f"""# Progress: {task_name}

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
""")
```

**Template reference:** `references/templates/progress.md` — use this exact structure.

**Update protocol (Subagent does after EACH step):**
```python
# After completing a step:
edit(progress_path, old="  - [ ] Step 1", new="  - [x] Step 1")
edit(progress_path, old="## Current\n- [ ] Step 1: ", new="## Current\n- [ ] Step 2: ...")
# Also update Status if DONE/BLOCKED
```

---

### 3. Launch Research Subagent

**When:** Need external facts, standards comparison, best practices  
**How (Main agent calls Task tool):**

```python
# Use whichever subagent type in your environment has:
# - Web search / fetching capability
# - File system read/write access
# - Ability to produce structured markdown output
# (e.g., "explore", "general", "researcher", "web-research", etc.)

Task(
    subagent_type="<your-research-capable-subagent>",
    description=f"Research: {topic}",
    prompt=f"""Research {topic}

Questions:
1. {question_1}
2. {question_2}

Sources to check:
- Official documentation: [URLs]
- GitHub: [repos]
- Standards bodies: [specs]

Output format: Structured markdown with citations
Save to: .research/{slugify(topic)}-research.md

Use template structure from references/templates/research-output.md
"""
)
```

**Output structure (subagent writes to `.research/`):** See `references/templates/research-output.md`

---

### 4. Launch Execution Subagent

**When:** Multi-step plan execution  
**How (Main agent calls Task tool):**

```python
# Use whichever subagent type in your environment can:
# - Read/write files
# - Run commands (validation)
# - Execute multi-step plans
# (e.g., "general", "builder", "coder", "exec", etc.)

Task(
    subagent_type="<your-execution-capable-subagent>",
    description=f"Execute: {phase_name}",
    prompt=f"""Execute {phase_name} of plan at .plans/{plan_file}

Plan phases to execute: {phase_numbers}
Files to modify: [list from plan]
Validation command: python3 validate.py --flag (or similar)

CRITICAL PROTOCOL:
1. Read plan: .plans/{plan_file}
2. Read progress: .plans/progress/{progress_file}
3. For EACH step:
   a. Do the step
   b. Update progress file: mark [x] Completed, update Current, Next
   c. Run validation
4. On blocker: Update progress Status=BLOCKED, describe blocker, STOP
5. On complete: Update progress Status=DONE, summary in Completed

Progress file: .plans/progress/{progress_file}
"""
)
```

---

### 5. Launch Validation Subagent

**When:** Need to verify outputs  
**How (Main agent calls Task tool):**

```python
# Use subagent type that can run validation commands and read files
# (e.g., "general", "validator", "tester", etc.)

Task(
    subagent_type="<your-validation-capable-subagent>",
    description="Validate outputs",
    prompt=f"""Validate {what_to_validate}

Validation commands:
- python3 validate.py --json file.json --md file.md --cyclonedx
- [other checks]

Save results to: .plans/progress/validation-{topic}.md
Report: PASS/FAIL with details
"""
)
```

---

### 6. Launch Planning Subagent

**When:** Need detailed plan from high-level goal  
**How (Main agent calls Task tool):**

```python
# Use subagent type good at analysis and task decomposition
# (e.g., "explore", "planner", "architect", "general", etc.)

Task(
    subagent_type="<your-planning-capable-subagent>",
    description=f"Plan: {goal}",
    prompt=f"""Create detailed plan for: {goal}

Goal: [measurable objective]
Constraints: [list]
Context: [relevant files, existing patterns]

Output: .plans/NN-name.md with full checklist
Use template structure from references/templates/plan-template.md

Include:
- Prerequisites
- Phases with atomic steps
- Affected files table
- Verification steps
- Dependencies
"""
)
```

---

## Anti-Patterns (Don't)

| Anti-pattern | Why Bad | Fix |
|--------------|---------|-----|
| Main writes code | Loses audit trail | Delegate to subagent |
| Subagent commits | No review | Main commits only |
| No progress file | Lost context | Write `.plans/progress/` |
| "Do everything" task | Context overflow, errors | Atomic tasks only |
| No validation step | Bugs in commit | Validate every step |
| Silent failures | Hidden breakage | Escalate blockers immediately |
| Progress not updated | Main blind | Update after EACH step |

---

## Quick Reference (Agent Mental Model)

```
MAIN AGENT                    SUBAGENT
──────────────────            ─────────────────
Creates plan                  Reads plan
Creates progress file         Updates progress after EACH step
Calls Task tool               Executes steps
Reviews progress              Runs validation
Commits (only Main)           Reports blockers immediately
                              Never commits
```

**Subagent selection by capability (not name):**

| Need | Use subagent that can... |
|------|--------------------------|
| Research | Web search, fetch docs, write `.research/` |
| Execution | Read/write files, run commands, multi-step |
| Validation | Run test/lint commands, report PASS/FAIL |
| Planning | Analyze codebase, decompose tasks, write plans |

---

## File Naming Conventions

| Type | Pattern | Example |
|------|---------|---------|
| Plan | `NN-kebab-case.md` | `04-add-cyclonedx-support.md` |
| Progress | `NN-kebab-case.md` (matches plan NN) | `04-add-cyclonedx-support.md` |
| Research | `topic-research.md` | `cyclonedx-naming-research.md` |

**Auto-numbering:** `NN = 2-digit sequential` (01, 02, 03...)

---

*Version 2.1.0: Added markdown format requirement for primary artifacts. Agent-native rewrite — no shell scripts.*
