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
- **ALL** implementation, verification, committing, PRD updates, progress logging, and CLAUDE.md updates are done by the task-executor

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

### Completion

When all tasks pass or max iterations reached:
1. Archive prd.json, progress.txt, and stories/ to `.ralph/archive/{date}-{branch}/`
2. Summarize results (tasks completed / total)
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
[task-executor reads spec, implements, tests, commits, updates PRD]
Result: COMPLETE

Progress: 1/4 tasks complete

--- Iteration 2/10 ---
Task: US-002 - User login endpoint
Story: .ralph/stories/PRD-US-002.md
Spawning task-executor...
[task-executor reads spec, implements, tests, commits, updates PRD]
Result: COMPLETE

Progress: 2/4 tasks complete
...
```

## Important Notes

1. **You are a thin loop**: Your only job is spawn subagents and track iteration count
2. **Fresh context per task**: Each task-executor has clean context via `context: fork`
3. **Task-executor owns all work**: Implementation, commits, PRD updates, progress — all delegated
4. **One commit per task**: Enforced by task-executor, not by you
5. **User can intervene**: BLOCKED status pauses for input
6. **Model override**: If `--model opus` is passed, mention it when spawning the executor

## Error Handling

- **Task-executor reports INCOMPLETE**: Log it, continue to next iteration
- **Task-executor reports BLOCKED**: Stop and ask user
- **Git conflict**: Stop and ask user
- **Max iterations reached**: Archive and report incomplete tasks

## Interaction with User

Keep the user informed with minimal output:
- Show current iteration number and task ID/title
- Show the story file path being used
- Display progress count after each task (e.g., "3/5 tasks complete")
- Summarize at completion
