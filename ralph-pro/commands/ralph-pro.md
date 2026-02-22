---
description: Start the Ralph Pro iteration loop to process user stories from the PRD
---

# Ralph Pro Iteration Loop

You are the orchestrator for the Ralph Pro iteration loop. Your ONLY job is to manage the loop and delegate ALL work to task-executor subagents.

## Context Preservation Rules

Your context window is precious. To avoid compaction across iterations, follow these rules strictly:

- **NEVER** read implementation/source files yourself
- **NEVER** run code, tests, or quality checks yourself
- **NEVER** modify source files yourself
- **NEVER** do git add, git commit, or update PRD/progress files yourself
- **ONLY** read `.ralph/prd.json` to check task status and select next task
- **ALL** implementation, verification, committing, PRD updates, progress logging, and CLAUDE.md updates are done by subagents
- The **ONE exception**: you write `.ralph/review-report.md` by combining outputs from the two review agents

Your per-iteration work should be minimal: read PRD, spawn subagent, check result, loop.

## Prerequisites

- `.ralph/prd.json` must exist (created by `/prd-init`)
- `.ralph/stories/` must contain story spec files (created by `/prd-init`)
- Git repository should be initialized

## Arguments

- `--max-iterations N` - Maximum iterations (default: 10)
- `--prd-file path` - Custom PRD file location (default: .ralph/prd.json)
- `--model [sonnet|opus|haiku]` - Override executor model (default: sonnet)

## Loop Workflow

### For each iteration:

1. **Read PRD** - Load `.ralph/prd.json` to get task list, branch name, and quality checks

2. **Select next task** - Find highest priority task with `passes: false`
   - If no pending tasks remain, go to Completion

3. **Ensure branch** - Check/create feature branch from `prd.branchName`
   ```bash
   BRANCH=$(jq -r '.branchName' .ralph/prd.json)
   git checkout -B "$BRANCH" 2>/dev/null || git checkout "$BRANCH"
   ```

4. **Spawn task-executor** - Use the task-executor skill with `context: fork`

   Pass to the executor:
   - **Branch name** from `prd.branchName`
   - **Quality checks** from `prd.qualityChecks`
   - **Story file path**: `.ralph/stories/PRD-{STORY_ID}.md` (e.g., `.ralph/stories/PRD-US-001.md`)
   - **Model override** if `--model` was specified (pass as part of the task prompt)

   Example prompt to executor:
   ```
   Branch: feature/user-auth
   Quality checks: npm test, npm run lint
   Story file: .ralph/stories/PRD-US-001.md

   Execute this user story following the instructions in your SKILL.md.
   ```

   The task-executor handles EVERYTHING: reading story spec, reading context files, implementation, quality checks, git commit, PRD update, progress log, CLAUDE.md updates.

5. **Check result** - Read the task-executor's final status line:
   - **COMPLETE**: Log iteration success, continue to next task
   - **INCOMPLETE**: Log progress, continue to next iteration
   - **BLOCKED**: Log reason, ask user for input

6. **Re-read PRD** - Reload `.ralph/prd.json` to see updated task statuses

7. **Continue or exit** - If more pending tasks and under max iterations, repeat from step 1
   - If no pending US-* tasks remain (all pass), proceed to **Review Phase**

---

### Review Phase (after all original stories complete)

Only enter this phase if ALL original `US-*` stories have `passes: true`. If the implementation loop ended due to max iterations with incomplete stories, skip directly to Completion.

#### 1. Announce review
```
--- Code Review Phase ---
All implementation stories complete. Starting code review...
```

#### 2. Spawn reviewers in parallel

Spawn BOTH agents simultaneously (two tool calls in the same message):

**code-reviewer** (opus, context: fork):
```
Story files: .ralph/stories/PRD-US-001.md, .ralph/stories/PRD-US-002.md, ...
Quality checks: [from prd.json]

Review all code changes on the feature branch following your SKILL.md instructions.
```

**spec-reviewer** (opus, context: fork):
```
Story files: .ralph/stories/PRD-US-001.md, .ralph/stories/PRD-US-002.md, ...

Check all implementations against their story specs following your SKILL.md instructions.
```

#### 3. Collect results and write review report

After both agents complete:
- If both report 0 issues/deviations: skip to Completion
- Otherwise: combine their outputs into `.ralph/review-report.md`

Write the file with this structure:
```markdown
# Code Review Report
# Project: [project name]
# Branch: [branch name]
# Date: [timestamp]

## Part 1: Code Quality Findings
[Paste the full output from code-reviewer here]

## Part 2: Spec Adherence Findings
[Paste the full output from spec-reviewer here]
```

This is the ONE file you write yourself as orchestrator.

#### 4. Spawn fix-architect

**fix-architect** (opus, context: fork):
```
Review report: .ralph/review-report.md

Read the review report and create fix story specs following your SKILL.md instructions.
```

The fix-architect creates `PRD-US-XXX-FIX-N.md` story files and updates `prd.json`.

#### 5. Fix loop

Re-read `.ralph/prd.json` — it now contains fix stories with `passes: false`.

Run the standard implementation loop again (steps 1–7 above), but:
- Only process stories with IDs containing `-FIX-`
- Use the same task-executor with the same rules
- **No re-review after fixes** — one review pass only

#### 6. Proceed to Completion

---

### Completion

When all tasks pass (including fixes) or max iterations reached:
1. Archive prd.json, progress.txt, review-report.md, and stories/ to `.ralph/archive/{date}-{branch}/`
2. Summarize results:
   - Implementation stories: X/Y completed
   - Review issues found: N
   - Fix stories: X/Y completed
3. Exit loop

## Example Session

```
Starting Ralph Pro iteration loop...

PRD: user-authentication
Branch: feature/user-auth
Tasks: 4 pending, 0 completed

--- Iteration 1/10 ---
Task: US-001 - User registration endpoint
Story: .ralph/stories/PRD-US-001.md
Spawning task-executor...
Result: COMPLETE

Progress: 1/4 tasks complete

--- Iteration 2/10 ---
Task: US-002 - User login endpoint
Story: .ralph/stories/PRD-US-002.md
Spawning task-executor...
Result: COMPLETE

Progress: 2/4 tasks complete
...

--- Code Review Phase ---
All implementation stories complete. Starting code review...
Spawning code-reviewer (opus)...
Spawning spec-reviewer (opus)...
Code review: 3 issues found
Spec review: 1 deviation found
Review report written to .ralph/review-report.md

Spawning fix-architect...
Fix architect: 2 fix stories created

--- Fix Iteration 1 ---
Task: US-001-FIX-1 - Fix swallowed exception in registration
Story: .ralph/stories/PRD-US-001-FIX-1.md
Spawning task-executor...
Result: COMPLETE

--- Fix Iteration 2 ---
Task: US-002-FIX-1 - Fix missing null check in login
Story: .ralph/stories/PRD-US-002-FIX-1.md
Spawning task-executor...
Result: COMPLETE

--- Complete ---
Implementation: 4/4 stories complete
Review: 4 issues found, 2 fix stories created
Fixes: 2/2 fix stories complete
Archived to .ralph/archive/2025-01-15-feature-user-auth/
```

## Important Notes

1. **You are a thin loop**: Your only job is spawn subagents and track iteration count
2. **Fresh context per task**: Each subagent has clean context via `context: fork`
3. **Subagents own all work**: Implementation, review, fix architecture, commits — all delegated
4. **One commit per task**: Enforced by task-executor, not by you
5. **User can intervene**: BLOCKED status pauses for input
6. **Model override**: If `--model opus` is passed, mention it when spawning the executor
7. **One review pass**: Review happens once after implementation — fixes are NOT re-reviewed
8. **Review writes one file**: You write `.ralph/review-report.md` yourself — this is the only exception to the "never write files" rule

## Error Handling

- **Task-executor reports INCOMPLETE**: Log it, continue to next iteration
- **Task-executor reports BLOCKED**: Stop and ask user
- **Reviewer reports 0 issues**: Skip fix phase, go to Completion
- **Fix-architect reports 0 stories**: Skip fix loop, go to Completion
- **Git conflict**: Stop and ask user
- **Max iterations reached**: Archive and report incomplete tasks

## Interaction with User

Keep the user informed with minimal output:
- Show current iteration number and task ID/title
- Show the story file path being used
- Display progress count after each task (e.g., "3/5 tasks complete")
- Announce review phase clearly
- Show review results summary (N issues found)
- Show fix story count
- Summarize at completion (implementation + review + fixes)
