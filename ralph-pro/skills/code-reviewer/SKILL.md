---
name: code-reviewer
description: Review code for bugs, silent failures, and simplification opportunities following project conventions.
allowed-tools: Read, Glob, Grep, Bash(git diff*, git log*, git show*), WebFetch, WebSearch
context: fork
---

# Code Reviewer

Review all code changes on the feature branch for bugs, silent failures, simplification opportunities, and style violations.

---

## RULES (Non-Negotiable)

- Review EVERY changed file, not just a sample
- Read the FULL file for context, not just the diff hunks
- Style reference is the project's own conventions (CLAUDE.md, linter config, existing patterns) — do NOT enforce external style guides
- Report real issues only — do not pad findings with nitpicks
- Every finding must include a concrete suggested fix
- Do NOT suggest changes that contradict the story specs

---

## Workflow

### 1. Read Context
- Read `.ralph/progress.txt` **in full** — this is the shared loop memory with learnings from all iterations
- Read `.ralph/prd.json` for project info and story list
- Read all story spec files from `.ralph/stories/PRD-US-*.md` to understand what was intended

### 2. Read Project Conventions
- Read all CLAUDE.md files in the project (root + module-level)
- Read linter/analyzer config if present:
  - Dart: `analysis_options.yaml`
  - TypeScript: `.eslintrc.*`, `tsconfig.json`
  - Python: `pyproject.toml`, `.flake8`, `ruff.toml`
- Note the patterns and conventions used in existing (pre-branch) code

### 3. Get the Diff
```bash
git diff main...HEAD
```
This gives you all changes introduced by the feature branch.

### 4. Review Each Changed File
For each file in the diff:
1. Read the **full file** (not just the diff) for surrounding context
2. Review the changes against these categories:

#### Bugs & Logic Errors
- Null safety issues (unguarded nullable access)
- Off-by-one errors in loops/indices
- Race conditions or incorrect async handling
- Incorrect state management (mutations where copies expected, missing state updates)
- Wrong operator or comparison logic
- Missing edge case handling

#### Silent Failures
- Swallowed exceptions (empty catch blocks, catch-all with no logging)
- Fallback behavior that hides errors (returning defaults instead of propagating failures)
- Ignored return values from operations that can fail
- Missing error propagation in async chains

#### Simplification Opportunities
- Unnecessary complexity that can be reduced without changing behavior
- Duplicate logic that should be extracted
- Overly verbose patterns where the language offers a cleaner idiom
- Unnecessary intermediate variables or redundant null checks
- Code that reimplements something already available in the codebase or standard library

#### Style Violations
- Violations of patterns documented in CLAUDE.md files
- Inconsistency with the existing codebase style
- Violations of the project's linter/analyzer rules

#### Dead Code
- Unused imports
- Unreachable branches
- Commented-out code left behind
- Unused variables or parameters

### 5. Output Findings

For each issue found, output in this format:

```
### [CATEGORY] - [file:line]
**Severity**: bug | simplification | style | dead-code | silent-failure
**Related story**: US-XXX
**Description**: Clear explanation of the issue
**Suggested fix**: Concrete code change or approach to fix it
---
```

### 6. Summary

End your response with:

```
## Code Review Summary

- Bugs: N
- Silent failures: N
- Simplification: N
- Style: N
- Dead code: N
- **Total: N issues**

REVIEW COMPLETE — N issues found
```
