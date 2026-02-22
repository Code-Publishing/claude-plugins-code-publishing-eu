---
description: Initialize a new PRD (Product Requirements Document) for Ralph Pro iteration loop
---

# PRD Initialization

You are initializing a new PRD for the Ralph Pro iteration loop. This is a three-phase process:
1. **Story Decomposition** — Understand the feature, generate user stories
2. **Architecture Derivation** — Explore the codebase, create detailed story specs with architecture
3. **QA Configuration** (optional) — Set up system-level test scenarios for end-to-end verification

---

## Phase 1: Story Decomposition

### 1. Understand the Request
Parse the user's feature description and ask clarifying questions about:
- Scope boundaries (what's in/out)
- User roles involved
- Quality check commands for this project (e.g., `npm test`, `fvm flutter test`)
- Branch naming preference

### 2. Detect Project Language
Inspect the project root for language indicators:
- `package.json` → typescript/javascript
- `pubspec.yaml` → dart
- `Cargo.toml` → rust
- `go.mod` → go
- `pyproject.toml` / `requirements.txt` → python
- `build.gradle` / `pom.xml` → java/kotlin

### 3. Generate User Stories
Create stories with:
- Clear IDs (US-001, US-002, etc.)
- Brief title
- Priority ordering (1 = highest)
- Stories small enough to complete in one iteration
- Each story independently testable

Present the story list to the user for approval before Phase 2.

---

## Phase 2: Architecture Derivation

### 1. Explore the Codebase
Before writing story specs, thoroughly explore the project to understand:
- **Project structure** — directory layout, module organization
- **Patterns** — how existing features are structured (services, controllers, repositories, etc.)
- **Conventions** — naming, error handling, validation approach, test structure
- **Existing utilities** — what's already built that stories can reuse
- **Test conventions** — framework, file naming, patterns used

### 2. Create Story Spec Files
For each user story, create `.ralph/stories/PRD-US-XXX.md` containing:

```markdown
# US-XXX: Story Title

## Description
As a [role], I want [goal] so that [benefit]

## Acceptance Criteria
- Specific testable criterion 1
- Specific testable criterion 2

## Context Files (Read These First)
- `path/to/file.ts` — why this file is relevant
- `path/to/other.ts` — pattern to follow

## Architecture

### Approach
What to build and how, referencing existing patterns.

### Rationale
Why this approach — reference existing code patterns, ADR-style reasoning.

### Files to Create/Modify
| Path | Action | Purpose |
|------|--------|---------|
| `src/...` | create | ... |
| `src/...` | modify | ... |

### Constraints
- MUST/MUST NOT rules tied to codebase conventions
- Enforced patterns (e.g., "MUST use express-validator, NOT inline validation")

### Implementation Steps
1. Create tests first (TDD)
2. Step-by-step implementation order
3. Integration wiring

### Test Cases
- `test('description')` — what it verifies
- `test('description')` — boundary case

### Type Signatures
- `methodName(param: Type): ReturnType`
```

**Key principles for story specs:**
- **Context Files** must reference REAL files discovered during codebase exploration
- **Constraints** must be derived from actual codebase patterns, not hypothetical
- **Implementation Steps** must start with tests (TDD)
- **Architecture** should follow existing patterns, not introduce new ones unnecessarily

### 3. Cross-Story Dependency Check
Ensure later stories build on earlier ones:
- If US-002 depends on code from US-001, the spec should reference what US-001 creates
- Implementation steps should account for artifacts from prior stories

### 4. Create Output Files

Create the directory structure:
```
.ralph/
├── prd.json          # Lean status tracker
├── stories/
│   ├── PRD-US-001.md
│   ├── PRD-US-002.md
│   └── ...
└── progress.txt
```

#### Lean `prd.json` (status tracking only)
```json
{
  "project": "feature-name",
  "branchName": "feature/feature-name",
  "description": "Overall feature description",
  "language": "typescript",
  "qualityChecks": ["npm test", "npm run lint"],
  "userStories": [
    { "id": "US-001", "title": "Story title", "priority": 1, "passes": false, "commitHash": null },
    { "id": "US-002", "title": "Story title", "priority": 2, "passes": false, "commitHash": null }
  ]
}
```

Note: All detailed descriptions, acceptance criteria, and architecture live in the story files, NOT in prd.json.

### 5. Initialize Supporting Files
- Create `.ralph/progress.txt` from template
- Optionally create root `CLAUDE.md` if one doesn't exist

---

## Phase 3: QA Configuration (Optional)

After stories and architecture specs are created, configure the optional QA step.

### 1. Ask the User

Ask:
> "Would you like to enable the QA (Quality Assurance) step? This adds automated system-level testing after implementation and code review using Playwright CLI and backend verification. It requires a test environment setup. (yes/no)"

If the user says **no**:
- Set `"qaEnabled": false` in `prd.json`
- Skip the rest of Phase 3
- Proceed to "After Creating PRD"

### 2. Check for SYSTEM_TEST_ENV.md

Look for `SYSTEM_TEST_ENV.md` in the **project root** (NOT inside `.ralph/`):
```bash
ls -la SYSTEM_TEST_ENV.md 2>/dev/null
```

### 3. If Missing: Help Create It

If `SYSTEM_TEST_ENV.md` does not exist, help the user create it. Ask about:

- **Test environment setup**: How to start/access the test environment (e.g., `docker compose up`, dev server URL)
- **Health check**: A command or URL to verify the environment is running
- **Client testing tool**: Default is Playwright CLI. Ask if they want a different tool.
- **Database access**: Connection string or command to query the test DB
- **Other services**: S3, Redis, message queues, etc. — how to verify side effects
- **Auth/credentials**: How to authenticate in the test environment (test user, API keys)
- **Cleanup**: How to reset test state between runs

Create `SYSTEM_TEST_ENV.md` in the project root using the template structure from `templates/system-test-env.md.template`.

### 4. Update prd.json

Add the QA configuration fields to `.ralph/prd.json`:
```json
{
  "qaEnabled": true,
  "qaConfig": {
    "systemTestEnvPath": "SYSTEM_TEST_ENV.md",
    "scenariosDir": ".ralph/qa-scenarios",
    "maxQaCycles": 3
  }
}
```

### 5. Create QA Scenarios Directory
```bash
mkdir -p .ralph/qa-scenarios
```

### 6. Spawn QA Planner

**qa-planner** (opus, context: fork):
```
PRD file: .ralph/prd.json
Story files: .ralph/stories/PRD-US-001.md, .ralph/stories/PRD-US-002.md, ...
System test env: SYSTEM_TEST_ENV.md

Read the PRD, all story specs, and the system test environment doc.
Create QA scenario files following your SKILL.md instructions.
```

The qa-planner creates `.ralph/qa-scenarios/QA-001.md`, `QA-002.md`, etc.

### 7. Confirm QA Scenarios

After the qa-planner completes, show the user:
- Number of QA scenarios created
- Brief summary of each scenario

Ask: "Are these QA scenarios acceptable? (yes / edit / skip QA)"
- **yes**: Proceed
- **edit**: Let user modify scenario files manually, then continue
- **skip QA**: Set `qaEnabled: false` in prd.json, remove `.ralph/qa-scenarios/`

---

## After Creating PRD

Tell the user:
1. PRD created at `.ralph/prd.json`
2. Story specs created in `.ralph/stories/`
3. How many user stories were created
4. Brief summary of architecture decisions
5. **QA status**: If enabled, how many QA scenarios were created. If disabled, mention it.
6. Next step: run `/ralph-pro` to start the iteration loop
