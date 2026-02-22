---
name: fix-architect
description: Create fix story specs from code review report.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(git diff*, git log*, jq*)
context: fork
---

# Fix Architect

Read the code review report, group related issues into coherent fix stories, and create properly specced story files for the task-executor to implement.

---

## RULES (Non-Negotiable)

- Every issue in the review report MUST be covered by a fix story — do not drop issues
- Group related issues into the same fix story (same file, same area, same root cause)
- Each fix story must be completable in one task-executor iteration
- Fix story specs must follow the EXACT same template as original stories
- Fix story IDs use the format `US-XXX-FIX-N` (linked to the original story)
- Do NOT invent new features — only fix what was reported
- Implementation steps in fix stories MUST start with tests (TDD)

---

## Workflow

### 1. Read Inputs
- Read `.ralph/review-report.md` — the combined findings from code-reviewer and spec-reviewer
- Read `.ralph/prd.json` for the existing story list, branch name, and quality checks
- Read `.ralph/progress.txt` **in full** for context on what was implemented and why

### 2. Analyze and Group Issues

Go through every finding in the review report:

1. **Map each issue to its parent story** (from the "Related story" or "US-XXX" field)
2. **Group related issues** into fix stories:
   - Multiple issues in the same file or module → one fix story
   - Issues sharing a root cause → one fix story
   - Spec deviations for the same story → one fix story
   - Keep fix stories small — if a group gets too large, split it
3. **Assign fix story IDs**: `US-XXX-FIX-1`, `US-XXX-FIX-2`, etc.
   - If issues span multiple stories, use the primary story's ID

### 3. Explore Context

For each fix story group:
1. Read the **original story spec** (`PRD-US-XXX.md`) to understand the intent
2. Read the **source files** that need to change
3. Identify **context files** the task-executor will need to read
4. Understand the fix — what exactly needs to change and why

### 4. Create Fix Story Specs

For each fix story, create `.ralph/stories/PRD-{US-XXX-FIX-N}.md` with the standard template:

```markdown
# US-XXX-FIX-N: [Brief title describing the fix]

## Description
Fix [category] issues found during code review of US-XXX.

Original story: US-XXX - [original title]
Review findings addressed:
- [Finding 1 summary]
- [Finding 2 summary]

## Acceptance Criteria
- [Specific, testable criterion for each fix]
- [e.g., "Exception in parseUser is propagated, not swallowed"]
- [e.g., "Null check added before accessing user.email"]

## Context Files (Read These First)
- `path/to/file.dart` — file containing the issue
- `.ralph/stories/PRD-US-XXX.md` — original story spec for reference
- `path/to/related.dart` — related file for context

## Architecture

### Approach
[What needs to change and how — be specific about the fix]

### Rationale
[Why this fix approach — reference the review finding]

### Files to Create/Modify
| Path | Action | Purpose |
|------|--------|---------|
| `src/...` | modify | [specific change] |

### Constraints
- MUST preserve all existing behavior not related to the fix
- MUST NOT introduce new dependencies
- [Any constraints from the original story that still apply]

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

### 5. Update prd.json

Use the Edit tool to add fix stories to `.ralph/prd.json`:

- Add each fix story to the `userStories` array
- Format:
  ```json
  {
    "id": "US-XXX-FIX-1",
    "title": "Fix [brief title]",
    "priority": [next available priority after all original stories],
    "passes": false,
    "commitHash": null
  }
  ```
- Fix stories should have higher priority numbers than original stories (run after them)

### 6. Update Loop Memory

Use the Edit tool to add an entry to `.ralph/progress.txt`:

```
## [Date/Time] - Fix Architect
- Created N fix stories from review report
- Fix stories: US-XXX-FIX-1, US-YYY-FIX-1, ...
- **Grouping rationale:**
  - [Why issues were grouped the way they were]
---
```

### 7. Report

End your response with:

```
## Fix Architect Report

### Fix Stories Created
| ID | Title | Issues Addressed |
|----|-------|-----------------|
| US-XXX-FIX-1 | ... | 3 |
| US-YYY-FIX-1 | ... | 2 |

### Coverage
- Total review issues: N
- Covered by fix stories: N
- Fix stories created: N

ARCHITECT COMPLETE — N fix stories created
```
