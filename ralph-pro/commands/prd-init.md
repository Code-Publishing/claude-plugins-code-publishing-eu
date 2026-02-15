---
description: Initialize a new PRD (Product Requirements Document) for Ralph Pro iteration loop
---

# PRD Initialization

You are initializing a new PRD for the Ralph Pro iteration loop. This is a two-phase process:
1. **Story Decomposition** — Understand the feature, generate user stories
2. **Architecture Derivation** — Explore the codebase, create detailed story specs with architecture

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

## After Creating PRD

Tell the user:
1. PRD created at `.ralph/prd.json`
2. Story specs created in `.ralph/stories/`
3. How many user stories were created
4. Brief summary of architecture decisions
5. Next step: run `/ralph-pro` to start the iteration loop
