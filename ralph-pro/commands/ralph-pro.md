---
description: Start the Ralph Pro iteration loop to process user stories from the PRD
---

# Ralph Pro Iteration Loop

You are the orchestrator for the Ralph Pro iteration loop. Your job is to process user stories from the PRD one at a time using subagents.

## Prerequisites

- `.ralph/prd.json` must exist (created by `/prd-init`)
- Git repository should be initialized

## Arguments

- `--max-iterations N` - Maximum iterations (default: 10)
- `--quality-checks "cmd"` - Override quality check commands
- `--skip-agents` - Skip AGENTS.md injection
- `--prd-file path` - Custom PRD file location (default: .ralph/prd.json)

## Loop Workflow

### For each iteration:

1. **Read PRD** - Load `.ralph/prd.json`

2. **Select next task** - Find highest priority task with `passes: false`
   ```bash
   # Use the select-next-task.sh script
   NEXT_TASK=$(./scripts/select-next-task.sh .ralph/prd.json)
   ```

3. **Check completion** - If no pending tasks, archive and exit

4. **Ensure branch** - Check/create feature branch from `prd.branchName`
   ```bash
   BRANCH=$(jq -r '.branchName' .ralph/prd.json)
   git checkout -B "$BRANCH" 2>/dev/null || git checkout "$BRANCH"
   ```

5. **Load AGENTS.md** - Discover relevant guidance
   ```bash
   AGENTS_CONTENT=$(./scripts/discover-agents.sh . content)
   ```

6. **Spawn task-executor** - Use the task-executor skill with `context: fork`
   - Pass: task definition, AGENTS.md content, quality checks
   - Wait for completion

7. **Process result** - Based on task-executor output:
   - **COMPLETE**:
     a. Stage changes: `git add -A`
     b. Commit with task ID: `git commit -m "[TASK_ID] TITLE"`
     c. Get commit hash
     d. Update prd.json: mark passes=true, store commitHash
     e. Log to progress.txt
   - **INCOMPLETE**: Log progress, continue to next iteration
   - **BLOCKED**: Log reason, ask user for input

8. **Quality checks** - Run quality check commands
   ```bash
   for cmd in $(jq -r '.qualityChecks[]' .ralph/prd.json); do
     eval "$cmd"
   done
   ```

9. **Continue or exit** - If more tasks and under max iterations, repeat

### Completion

When all tasks pass or max iterations reached:
1. Archive prd.json and progress.txt to `.ralph/archive/{date}-{branch}/`
2. Summarize results
3. Exit loop

## Commit Message Format

```
[US-001] Brief title of the story

Implements user story: "As a user, I want..."

Acceptance criteria met:
- [x] Criterion 1
- [x] Criterion 2

🤖 Generated with Ralph Pro
```

## Example Session

```
Starting Ralph Pro iteration loop...

PRD: user-authentication
Branch: feature/user-auth
Tasks: 4 pending, 0 completed

--- Iteration 1/10 ---
Task: US-001 - User registration endpoint
Spawning task-executor...
[task-executor works on the task]
Result: COMPLETE

Committing: [US-001] User registration endpoint
Commit: abc1234

Quality checks:
- npm test: PASSED
- npm run lint: PASSED

Progress: 1/4 tasks complete

--- Iteration 2/10 ---
Task: US-002 - User login endpoint
...
```

## Important Notes

1. **Fresh context per task**: Each task-executor has clean context
2. **Parent tracks state**: PRD and progress are managed by the parent
3. **One commit per task**: Clean git history
4. **Automatic archiving**: Completed loops are preserved
5. **User can intervene**: BLOCKED status pauses for input

## Error Handling

- **Quality check failure**: Do NOT mark task complete, log failure, continue
- **Git conflict**: Stop and ask user
- **Max iterations**: Archive and report incomplete tasks
- **Subagent failure**: Log error, mark task incomplete, continue

## Interaction with User

Keep the user informed:
- Show current iteration and task
- Display progress after each task
- Report quality check results
- Summarize at completion
