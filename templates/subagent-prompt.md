# Subagent Prompt Templates

## Research Subagent

```
Task: "Research [Topic]"
Prompt: |
  Research [Topic]
  
  Questions:
  1. Q1
  2. Q2
  
  Sources: [official docs, GitHub, standards bodies]
  Output: Structured report with citations
  Save to: .research/[topic].md
```

## Execution Subagent

```
Task: "Execute Phase N"
Prompt: |
  Execute Phase N of plan at .plans/NN-name.md
  
  Files to modify: [list]
  Validation: python3 validate.py --flag
  
  After each step: update .plans/progress/XX-name.md
```

## Plan Subagent

```
Task: "Create Plan for X"
Prompt: |
  Create plan for X.
  Goal: [measurable]
  Constraints: [list]
  Output: .plans/NN-name.md with checklist
```

## Plan Execution Subagent

```
Task: "Execute Plan X"
Prompt: |
  Execute Phase N of plan .plans/NN-name.md
  Start at Phase N. Update .plans/progress/XX-name.md after each step.
  Validate with: python3 validate.py --flag
```

## Plan Subagent

```
Task: "Create Plan for X"
Prompt: |
  Create plan for X.
  Goal: [measurable]
  Constraints: [list]
  Output: .plans/NN-name.md with checklist
```

### Progress Tracking Command

```bash
# Check progress
cat .plans/progress/XX-name.md

# Update after step
sed -i 's/\[ \] Step N/\[x\] Step N/' .plans/progress/XX-name.md
```

---

## Progress File Template

```markdown
# Progress: [Task Name]

## Status: IN_PROGRESS / DONE / BLOCKED

## Completed
- [x] Step 1
- [x] Step 2

## Current
- [ ] Step 3: ...

## Blockers
- None / [Description]

## Next
- Step 4: ...
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