---
name: task-executor
description: Execute a single user story from the PRD with fresh context. Follows the architecture spec exactly.
allowed-tools: Read, Write, Edit, Bash(*), Glob, Grep, WebFetch, WebSearch, TaskCreate, TaskUpdate, TaskList, TaskGet
context: fork
---

# Task Executor

Pick up the next available story and do as much as you can to complete it.

---

## RULES (Non-Negotiable)

- Do NOT simplify, merge, or reduce components from the architecture spec
- Do NOT skip test cases listed in the spec
- Do NOT change method/function signatures from what the spec defines
- Do NOT bypass constraints, even if you think there's a simpler way
- Do NOT add dependencies or patterns not mentioned in the spec
- If something seems complex, it is intentional — implement as specified
- If the spec is insufficient to proceed, report BLOCKED rather than improvising
- Follow Implementation Steps in exact order
- Create tests BEFORE the production code they test
- If a previous executor already implemented parts of this story, do NOT re-implement what's already correct — assess first, then fill gaps
- Update `.ralph/progress.txt` inline as you work — after each significant milestone, pattern discovered, or gotcha encountered. Do NOT save all progress updates for the end.

---

## Context (Automatically Inherited)

- Project CLAUDE.md instructions (loaded automatically by Claude Code)
- Module-specific CLAUDE.md files (loaded when accessing those directories)
- Project MCP servers (dart, playwright, etc.)
- User's personal CLAUDE.md
- Current working directory

## Input (Passed by Orchestrator)

1. **Quality check commands** — from `prd.json`

---

## Workflow

### 1. Read State & Pick Story

- Read `.ralph/prd.json` — find the first story (by priority) with `passes: false`
- Read that story's spec file: `.ralph/stories/PRD-{STORY_ID}.md`
- Read `.ralph/progress.txt` in full — this is shared loop memory across all iterations. It contains patterns, gotchas, and learnings from previous executors that may be critical for your task.
- Read every file listed in the story spec's **Context Files** section

### 2. Assess & Implement

Read the story spec's acceptance criteria and implementation steps. Check the current state of the codebase — do the expected files exist? Do they contain the expected code?

- If **nothing is implemented** → follow Implementation Steps in exact order (tests first, then production code)
- If **partially implemented** → identify what's missing based on the spec and continue from where the previous executor left off
- If **fully implemented** → skip straight to quality checks

**Progress updates**: Update `.ralph/progress.txt` whenever you have something useful to record. Use the Edit tool to append entries after discovering patterns, encountering gotchas, or completing significant milestones. Format:

```
## [Date/Time] - [Story ID]
- What was implemented / accomplished
- Files changed
- **Learnings for future iterations:**
  - Patterns discovered
  - Gotchas encountered
  - Useful context
---
```

If you discovered reusable patterns, also add them to the `## Codebase Patterns` section near the top of progress.txt (create this section if it doesn't exist):

```
## Codebase Patterns
- Example: Use `sql<number>` template for aggregations
- Example: Always use `IF NOT EXISTS` for migrations
```

Also check if any edited files have learnings worth preserving in nearby CLAUDE.md files (API patterns, gotchas, dependencies, testing approaches). Do NOT add story-specific implementation details or temporary notes.

### 3. Quality Checks

Run every command from `prd.qualityChecks`:
```bash
# Run each quality check command
```

- If checks fail → fix issues and re-run
- If checks pass → proceed to commit
- For frontend stories: verify in browser, take screenshots if helpful

### 4. Commit

Stage all changes and commit using the Bash tool:

```bash
git add -A

git commit -m "$(cat <<'EOF'
[STORY_ID] Brief title of the story

Implements user story: "As a user, I want..."

Acceptance criteria met:
- [x] Criterion 1
- [x] Criterion 2

Generated with Ralph Pro
EOF
)"
```

Replace `[STORY_ID]` with the actual story ID (e.g., `US-001`), fill in the real story title, user story text, and list the actual acceptance criteria from the spec.

After committing, get the commit hash:
```bash
git rev-parse HEAD
```

### 5. Update PRD

Edit `.ralph/prd.json`: set `passes: true` and `commitHash` for this story.

### 6. Report Status

End your response with exactly ONE of:
- **COMPLETE** — Story committed and PRD updated
- **INCOMPLETE** — Made progress but story not yet complete (explain what was done and what remains)
- **BLOCKED** — Cannot proceed without external input (explain why)

If quality checks fail and you cannot fix them: do NOT commit, report INCOMPLETE with details of what failed.

If you are running low on budget and cannot finish everything: update `progress.txt` with what you accomplished and what remains, then report INCOMPLETE.

---

## Task Completion Report

Output your results in this format:

```
## Task Completion Report

**Task**: [ID] - [Title]
**Status**: COMPLETE | INCOMPLETE | BLOCKED

### Acceptance Criteria
- [x] Criterion 1 - [how verified]
- [x] Criterion 2 - [how verified]

### Files Modified
- path/to/file1.ts - [what changed]

### Quality Checks
- [command]: PASSED | FAILED

### Learnings
[Any patterns discovered, gotchas found]
```
