---
description: Initialize a new PRD (Product Requirements Document) for Ralph Pro iteration loop
---

# PRD Initialization

You are initializing a new PRD (Product Requirements Document) for the Ralph Pro iteration loop.

## Your Task

Based on the user's description, create a structured PRD with user stories.

## Process

1. **Understand the request**: Parse the user's feature description
2. **Ask clarifying questions** if needed about:
   - Scope boundaries (what's in/out)
   - User roles involved
   - Quality check commands for this project
   - Branch naming preference
3. **Generate user stories** with:
   - Clear IDs (US-001, US-002, etc.)
   - User story format: "As a [role], I want [goal] so that [benefit]"
   - Specific, testable acceptance criteria
   - Priority ordering (1 = highest)
4. **Create the PRD file** at `.ralph/prd.json`
5. **Initialize progress.txt** at `.ralph/progress.txt`
6. **Optionally create AGENTS.md** if one doesn't exist

## PRD JSON Structure

```json
{
  "project": "feature-name",
  "branchName": "feature/feature-name",
  "description": "Overall feature description",
  "qualityChecks": [
    "command to run tests",
    "command to run linter"
  ],
  "userStories": [
    {
      "id": "US-001",
      "title": "Brief title",
      "description": "As a [role], I want [goal] so that [benefit]",
      "acceptanceCriteria": [
        "Specific testable criterion 1",
        "Specific testable criterion 2"
      ],
      "priority": 1,
      "passes": false,
      "commitHash": null,
      "notes": "Optional implementation notes"
    }
  ]
}
```

## Guidelines

- Keep user stories **small enough to complete in one iteration**
- Each story should be **independently testable**
- Acceptance criteria must be **specific and verifiable**
- Stories with lower priority numbers are processed first
- Include quality check commands appropriate for the project

## Example

User: "Build user authentication with JWT"

Generated PRD:
```json
{
  "project": "user-authentication",
  "branchName": "feature/user-auth",
  "description": "Implement user authentication system with JWT tokens",
  "qualityChecks": ["npm test", "npm run lint"],
  "userStories": [
    {
      "id": "US-001",
      "title": "User registration endpoint",
      "description": "As a new user, I want to register with email and password so that I can create an account",
      "acceptanceCriteria": [
        "POST /auth/register accepts email and password",
        "Validates email format and password strength",
        "Returns 201 with user ID on success",
        "Returns 400 with validation errors on failure",
        "Stores password as bcrypt hash"
      ],
      "priority": 1,
      "passes": false,
      "commitHash": null,
      "notes": ""
    },
    {
      "id": "US-002",
      "title": "User login endpoint",
      "description": "As a registered user, I want to log in so that I can access protected resources",
      "acceptanceCriteria": [
        "POST /auth/login accepts email and password",
        "Returns JWT token on valid credentials",
        "Returns 401 on invalid credentials",
        "JWT contains user ID and expiration"
      ],
      "priority": 2,
      "passes": false,
      "commitHash": null,
      "notes": ""
    }
  ]
}
```

## After Creating PRD

Tell the user:
1. PRD created at `.ralph/prd.json`
2. Progress log initialized at `.ralph/progress.txt`
3. How many user stories were created
4. Next step: run `/ralph-pro` to start the iteration loop
