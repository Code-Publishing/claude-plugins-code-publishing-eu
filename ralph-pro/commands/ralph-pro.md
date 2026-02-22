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
- **Exception 1**: you write `.ralph/review-report.md` by combining outputs from the two review agents
- **Exception 2**: you write/reset `.ralph/test_report.md` at the start of each QA cycle

Your per-iteration work should be minimal: read PRD, spawn subagent, check result, loop.

## Prerequisites

- `.ralph/prd.json` must exist (created by `/prd-init`)
- `.ralph/stories/` must contain story spec files (created by `/prd-init`)
- Git repository should be initialized

## Arguments

- `--max-iterations N` - Maximum iterations (default: 30)
- `--prd-file path` - Custom PRD file location (default: .ralph/prd.json)
- `--model [sonnet|opus|haiku]` - Override executor model (default: sonnet)
- `--skip-qa` - Skip QA phase even if qaEnabled is true in prd.json

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
- Only process stories with IDs containing `-FIX-` (at this point, only review fix stories exist — QA fix stories are created later)
- Use the same task-executor with the same rules
- **No re-review after fixes** — one review pass only

#### 6. Proceed to QA Phase (or Completion if QA disabled)

---

### QA Phase (after review+fix phase)

Only enter this phase if ALL of these conditions are met:
- `prd.json` has `"qaEnabled": true`
- `--skip-qa` was NOT passed
- `.ralph/qa-scenarios/` contains at least one `QA-*.md` file
- The implementation loop did NOT end due to max iterations with incomplete stories

If any condition is not met, skip to Completion.

#### QA Loop

The QA loop is a cycle: run tests → create fix stories → implement fixes → re-test. It repeats until all tests pass or the budget is exhausted.

**Budget rules:**
- Each QA fix story iteration counts toward the global `--max-iterations` budget
- The QA-test-then-fix cycle repeats at most `qaConfig.maxQaCycles` times (default: 3)
- If the global iteration budget is exhausted during QA, stop and proceed to Completion

#### 1. Announce QA Phase
```
--- QA Phase ---
QA enabled. Running system-level test scenarios...
QA cycle budget: N cycles remaining
Global iteration budget: M iterations remaining
```

#### 2. Run QA Scenarios

List all `.ralph/qa-scenarios/QA-*.md` files, sorted by ID.

**Before the first qa-agent of each cycle**: Reset `.ralph/test_report.md` by writing just the header:
```markdown
# QA Test Report
# Project: [project name]
# Branch: [branch name]
# QA Cycle: N
# Date: [timestamp]
```
This is the SECOND file you write yourself as orchestrator (in addition to review-report.md).

For each scenario file, spawn a **qa-agent** (sonnet, context: fork) ONE AT A TIME (sequential, not parallel):

```
Scenario file: .ralph/qa-scenarios/QA-001.md
System test env: SYSTEM_TEST_ENV.md
Test report: .ralph/test_report.md

Execute this QA scenario following your SKILL.md instructions.
```

After each qa-agent completes, check its status:
- **QA ENV_UNAVAILABLE**: Stop running further scenarios for this cycle. The environment is down.
- **QA PASSED / QA FAILED / QA BLOCKED**: Continue to next scenario.

#### 3. Check Test Report

After all qa-agents complete for this cycle, read `.ralph/test_report.md`:

- If **all scenarios PASSED**: QA is done. Announce success, proceed to Completion.
  ```
  --- QA Complete ---
  All QA scenarios passed on cycle N.
  ```

- If **any scenario has ENV_UNAVAILABLE**: QA cannot proceed. Announce and skip to Completion.
  ```
  --- QA Aborted ---
  Test environment unavailable. See .ralph/test_report.md for details.
  Proceeding to completion without QA validation.
  ```

- If **any scenario FAILED**: Continue to step 4.

#### 4. Spawn QA Fix Architect

**qa-fix-architect** (opus, context: fork):
```
Test report: .ralph/test_report.md
PRD file: .ralph/prd.json
Story files: [list all original US-* story file paths]

Read the test report and create QA fix stories following your SKILL.md instructions.
```

The qa-fix-architect creates `PRD-US-XXX-QA-FIX-N.md` story files and updates prd.json.

If the qa-fix-architect reports 0 fix stories created, skip the fix loop and proceed to the next QA cycle or Completion.

#### 5. QA Fix Implementation Loop

Re-read `.ralph/prd.json` — it now contains QA fix stories with `passes: false`.

Run the standard implementation loop (steps 1–7 from the main loop), but:
- Only process stories with IDs containing `-QA-FIX-`
- Use the same task-executor with the same rules
- Each iteration counts toward the global `--max-iterations` budget
- **No re-review after QA fixes** — go straight back to QA testing

#### 6. Re-test (Loop Back)

After all QA fix stories are implemented (or budget exhausted):
- Decrement the QA cycle counter
- If QA cycles remaining > 0 AND global iterations remaining > 0: go back to step 2
- Otherwise: proceed to Completion with partial QA results

#### 7. QA Loop Flow Summary

```
QA Phase Entry
│
├─► [Cycle N]
│   ├─ Reset test_report.md
│   ├─ Run qa-agent for each QA-*.md scenario (sequential)
│   ├─ All passed? ──► YES ──► Completion (QA success)
│   ├─ Env unavailable? ──► YES ──► Completion (QA aborted)
│   ├─ Failures? ──► Spawn qa-fix-architect
│   ├─ Implement QA fix stories (task-executor loop)
│   └─ Cycles remaining? ──► YES ──► Loop back to [Cycle N+1]
│                          ──► NO  ──► Completion (QA budget exhausted)
│
Completion
```

---

### Completion

When all tasks pass (including fixes and QA fixes) or max iterations reached:
1. Archive prd.json, progress.txt, review-report.md, stories/, qa-scenarios/, and test_report.md to `.ralph/archive/{date}-{branch}/`
2. Summarize results:
   - Implementation stories: X/Y completed
   - Review issues found: N
   - Fix stories: X/Y completed
   - **QA status**: Enabled/Disabled/Skipped
   - **QA scenarios**: X total, Y passed, Z failed (if QA ran)
   - **QA cycles used**: N of M (if QA ran)
   - **QA fix stories**: X/Y completed (if QA fixes were needed)
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

--- QA Phase ---
QA enabled. Running system-level test scenarios...
QA cycle budget: 3 cycles remaining
Global iteration budget: 15 iterations remaining

--- QA Cycle 1 ---
Scenario: QA-001 - User registration flow
Spawning qa-agent...
Result: QA PASSED

Scenario: QA-002 - User login flow
Spawning qa-agent...
Result: QA FAILED

QA Cycle 1: 1/2 passed, 1/2 failed

Spawning qa-fix-architect...
QA fix architect: 1 fix story created

--- QA Fix Iteration 1 ---
Task: US-002-QA-FIX-1 - Fix login redirect after auth
Story: .ralph/stories/PRD-US-002-QA-FIX-1.md
Spawning task-executor...
Result: COMPLETE

--- QA Cycle 2 ---
Scenario: QA-001 - User registration flow
Result: QA PASSED

Scenario: QA-002 - User login flow
Result: QA PASSED

--- QA Complete ---
All QA scenarios passed on cycle 2.

--- Complete ---
Implementation: 4/4 stories complete
Review: 4 issues found, 2 fix stories created
Fixes: 2/2 fix stories complete
QA: 2/2 scenarios passed (2 cycles, 1 QA fix story)
Archived to .ralph/archive/2025-01-15-feature-user-auth/
```

## Important Notes

1. **You are a thin loop**: Your only job is spawn subagents and track iteration count
2. **Fresh context per task**: Each subagent has clean context via `context: fork`
3. **Subagents own all work**: Implementation, review, fix architecture, QA testing, commits — all delegated
4. **One commit per task**: Enforced by task-executor, not by you
5. **User can intervene**: BLOCKED status pauses for input
6. **Model override**: If `--model opus` is passed, mention it when spawning the executor
7. **One review pass**: Review happens once after implementation — fixes are NOT re-reviewed
8. **Orchestrator writes two files**: You write `.ralph/review-report.md` and reset `.ralph/test_report.md` — these are the only exceptions to the "never write files" rule
9. **QA is optional**: Only runs if `qaEnabled: true` in prd.json and `--skip-qa` not passed
10. **QA scenarios are sequential**: One qa-agent at a time to avoid environment conflicts
11. **QA budget is shared**: QA fix iterations count toward global --max-iterations
12. **Task-executor isolation**: The task-executor never receives QA scenario files — only standard story specs from .ralph/stories/

## Error Handling

- **Task-executor reports INCOMPLETE**: Log it, continue to next iteration
- **Task-executor reports BLOCKED**: Stop and ask user
- **Reviewer reports 0 issues**: Skip fix phase, go to QA Phase (or Completion)
- **Fix-architect reports 0 stories**: Skip fix loop, go to QA Phase (or Completion)
- **Git conflict**: Stop and ask user
- **Max iterations reached**: Archive and report incomplete tasks
- **QA environment unavailable**: qa-agent reports ENV_UNAVAILABLE. Orchestrator aborts QA, proceeds to Completion.
- **All QA tests pass first cycle**: Skip qa-fix-architect, proceed to Completion.
- **QA cycle budget exhausted**: Log remaining failures, proceed to Completion.
- **Global iteration budget reached during QA fixes**: Archive and report, noting incomplete QA.
- **No QA scenarios exist**: Skip QA phase entirely (even if qaEnabled is true).
- **QA fix architect creates 0 stories**: Skip fix loop, proceed to next QA cycle or Completion.

## Interaction with User

Keep the user informed with minimal output:
- Show current iteration number and task ID/title
- Show the story file path being used
- Display progress count after each task (e.g., "3/5 tasks complete")
- Announce review phase clearly
- Show review results summary (N issues found)
- Show fix story count
- Announce QA phase with cycle and iteration budget
- Show QA scenario results (PASSED/FAILED per scenario)
- Show QA cycle summary (N/M passed)
- Summarize at completion (implementation + review + fixes + QA)
