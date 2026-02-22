---
name: qa-planner
description: Create end-to-end QA test scenarios from PRD stories and system test environment.
allowed-tools: Read, Write, Glob, Grep, Bash(jq*), WebFetch, WebSearch
context: fork
---

# QA Planner

Create end-to-end QA test scenarios that verify the implemented feature from the user's perspective.

---

## RULES (Non-Negotiable)

- Scenarios test USER-VISIBLE BEHAVIOR, not implementation details
- Each scenario must be independently executable
- Scenarios must reference ONLY capabilities described in SYSTEM_TEST_ENV.md
- Do NOT create scenarios that require tools/access not documented in SYSTEM_TEST_ENV.md
- Do NOT duplicate unit test coverage — focus on integration and end-to-end flows
- Scenarios must include BOTH the happy path AND key error paths
- Each scenario must have clear pass/fail criteria
- Keep scenario count reasonable (typically 3–8 per feature)
- Scenarios must be ordered by dependency (independent ones first)

---

## Workflow

### 1. Read Inputs
- Read `.ralph/prd.json` for project overview and story list
- Read ALL story spec files from `.ralph/stories/PRD-US-*.md`
- Read `SYSTEM_TEST_ENV.md` for test environment capabilities
- Read `.ralph/progress.txt` if it exists for context

### 2. Understand the Feature Holistically

Before writing scenarios, build a mental model of:
- What the user can DO after all stories are implemented
- What the user-facing entry points are (UI pages, API endpoints, CLI commands)
- What side effects should be observable (DB records, files created, emails sent)
- What error states the user might encounter

### 3. Design Test Scenarios

Create scenarios that cover:

**Happy paths:**
- Core user flows end-to-end (e.g., register → login → use feature)
- Each major capability at least once

**Error paths:**
- Invalid input handling
- Unauthorized access
- Missing prerequisites

**Integration checks:**
- Data flows between components (e.g., form submission → DB → API response)
- Side effects (e.g., S3 uploads, email sends) if verifiable per SYSTEM_TEST_ENV.md

### 4. Write Scenario Files

Create `.ralph/qa-scenarios/` directory if it doesn't exist:
```bash
mkdir -p .ralph/qa-scenarios
```

For each scenario, create `.ralph/qa-scenarios/QA-XXX.md`:

```markdown
# QA-XXX: [Scenario Title]

## Objective
[One sentence: what user-facing behavior this verifies]

## Prerequisites
- [Environment state required before this test]
- [Data that must exist]
- [Services that must be running]

## Test Steps

### Step 1: [Action description]
**Action**: [What to do — e.g., navigate to URL, call API, click button]
**Expected**: [What should happen]
**Verify**: [How to check — e.g., check HTTP status, query DB, inspect UI element]

### Step 2: [Action description]
**Action**: ...
**Expected**: ...
**Verify**: ...

[...more steps...]

## Pass Criteria
- [ ] [Criterion 1 — specific, observable]
- [ ] [Criterion 2]

## Fail Criteria
- [ ] [Condition that means the test failed]

## Backend Verification
- [DB query to run and expected result]
- [S3/storage check if applicable]
- [Log entry to verify if applicable]

## Playwright Hints
[CSS selectors, URL patterns, or API endpoints that help automate this scenario]
```

### 5. Assign Scenario IDs

Use sequential IDs: QA-001, QA-002, QA-003, etc.

Order by dependency:
- Independent scenarios first
- Scenarios that depend on state from earlier scenarios later

### 6. Report

End your response with:

```
## QA Planning Report

### Scenarios Created
| ID | Title | Type | Stories Covered |
|----|-------|------|----------------|
| QA-001 | ... | happy-path | US-001, US-002 |
| QA-002 | ... | error-path | US-001 |

### Coverage
- User stories covered: N/M
- Happy path scenarios: N
- Error path scenarios: N
- Integration scenarios: N

QA PLANNING COMPLETE — N scenarios created
```
