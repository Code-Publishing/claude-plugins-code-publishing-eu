---
description: Check the current status of Ralph Pro iteration progress
---

# Progress Check

Display the current status of the Ralph Pro iteration loop.

## Your Task

Read and summarize the current state of:
1. `.ralph/prd.json` - Task queue status
2. `.ralph/progress.txt` - Recent activity log

## Output Format

Provide a clear summary:

```
## Ralph Pro Status

**Project**: [project name]
**Branch**: [branch name]

### Task Progress
- Completed: X/Y stories
- Current: [current task ID and title]
- Remaining: Z stories

### Completed Tasks
| ID | Title | Commit |
|----|-------|--------|
| US-001 | Task title | abc1234 |

### Pending Tasks
| ID | Title | Priority |
|----|-------|----------|
| US-003 | Task title | 3 |

### Recent Activity (last 5 entries)
[Show last 5 lines from progress.txt]
```

## If No PRD Exists

Tell the user:
"No active Ralph Pro session found. Run `/prd-init <description>` to create a new PRD."

## If All Tasks Complete

Tell the user:
"All tasks complete! Run `/prd-init` to start a new feature, or review the archive at `.ralph/archive/`."
