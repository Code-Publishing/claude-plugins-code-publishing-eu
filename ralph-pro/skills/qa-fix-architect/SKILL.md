---
name: qa-fix-architect
description: Create fix story specs from QA test report failures.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(git diff*, git log*, jq*)
context: fork
---

# QA Fix Architect

Read the QA test report, analyze failures, determine root causes in the codebase, and create fix story specs for the task-executor.

---

## RULES (Non-Negotiable)

- Every FAILED scenario must be analyzed — do not skip any
- Fix stories address ROOT CAUSES, not symptoms — a UI glitch may be caused by a backend bug
- Fix story IDs use format `US-XXX-QA-FIX-N` where XXX is the most relevant original story
- Do NOT create fix stories for ENV_UNAVAILABLE scenarios — those are infrastructure issues
- Fix story specs follow the EXACT same template as original stories
- Each fix story must be completable in one task-executor iteration
- Implementation steps in fix stories MUST start with tests (TDD)
- Do NOT include QA scenario files in fix story Context Files — task-executor must not see them
- Include ONLY source code files and original story specs in Context Files
- Group related failures into the same fix story when they share a root cause

---

## Workflow

### 1. Read Inputs
- Read `.ralph/test_report.md` — the QA test results
- Read `.ralph/prd.json` for existing story list and project info
- Read `.ralph/progress.txt` **in full** for context
- Read all original story specs from `.ralph/stories/PRD-US-*.md`

### 2. Analyze Failures

For each FAILED scenario in the test report:
1. Identify which test steps failed and why
2. Identify which acceptance criteria from original stories are affected
3. Read the source files involved
4. Determine the root cause:
   - Missing implementation?
   - Incorrect logic?
   - Integration wiring issue?
   - State management bug?
   - Frontend rendering issue?

### 3. Group and Plan Fixes

1. **Map each failure to its root cause story** — which US-XXX story's implementation caused this?
2. **Group related failures** sharing a root cause into one fix story
3. **Assign IDs**: `US-XXX-QA-FIX-1`, `US-XXX-QA-FIX-2`, etc.
   - If a fix spans multiple stories, use the primary story's ID
   - Number sequentially within each parent story

### 4. Explore Context

For each fix group:
1. Read the original story spec
2. Read the source files that need to change
3. Identify context files the task-executor will need
4. Plan the specific fix

### 5. Create Fix Story Specs

For each fix story, create `.ralph/stories/PRD-{US-XXX-QA-FIX-N}.md`:

```markdown
# US-XXX-QA-FIX-N: [Brief title describing the fix]

## Description
Fix issues found during QA testing related to US-XXX.

Original story: US-XXX - [original title]
QA failures addressed:
- [QA-YYY step N: what failed and why]
- [QA-ZZZ step M: what failed and why]

## Acceptance Criteria
- [Specific, testable criterion for each fix]
- [Focus on the behavior that should work correctly]

## Context Files (Read These First)
- `path/to/file.ts` — file containing the issue
- `.ralph/stories/PRD-US-XXX.md` — original story spec for reference

## Architecture

### Approach
[What needs to change and how — be specific about the fix]

### Rationale
[Why this fix — reference the QA failure details]

### Files to Create/Modify
| Path | Action | Purpose |
|------|--------|---------|
| `src/...` | modify | [specific change] |

### Constraints
- MUST preserve all existing behavior not related to the fix
- MUST NOT introduce new dependencies
- MUST NOT reference or read QA scenario files

### Implementation Steps
1. Write a test that demonstrates the current incorrect behavior
2. Write a test that expects the correct behavior
3. Run both — second should fail
4. Implement the fix
5. Run tests — first should now fail (behavior changed)
6. Remove the test demonstrating the issue, keep the one expecting correct behavior

### Test Cases
- `test('[description of what the fix verifies]')` — [what it checks]
```

**CRITICAL**: The Context Files section must NEVER reference `.ralph/qa-scenarios/*` files. The task-executor must not know about QA scenarios.

### 6. Update prd.json

Use the Edit tool to add QA fix stories to `.ralph/prd.json`:

- Add each fix story to the `userStories` array
- Format:
  ```json
  {
    "id": "US-XXX-QA-FIX-1",
    "title": "Fix [brief title]",
    "priority": [next available priority after all existing stories],
    "passes": false,
    "commitHash": null
  }
  ```
- QA fix stories should have higher priority numbers than all existing stories

### 7. Update Loop Memory

Use the Edit tool to append to `.ralph/progress.txt`:

```
## [Date/Time] - QA Fix Architect
- Created N fix stories from QA test report
- Fix stories: US-XXX-QA-FIX-1, US-YYY-QA-FIX-1, ...
- **Root cause analysis:**
  - [What caused the QA failures]
  - [Grouping rationale]
---
```

### 8. Report

End your response with:

```
## QA Fix Architect Report

### Fix Stories Created
| ID | Title | QA Scenarios Addressed |
|----|-------|----------------------|
| US-XXX-QA-FIX-1 | ... | QA-001, QA-002 |
| US-YYY-QA-FIX-1 | ... | QA-003 |

### Coverage
- Failed QA scenarios: N
- Root causes identified: N
- Fix stories created: N

QA ARCHITECT COMPLETE — N fix stories created
```
