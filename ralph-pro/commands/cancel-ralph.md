---
description: Cancel the active Ralph Pro iteration loop and archive progress
---

# Cancel Ralph Pro

Cancel the current Ralph Pro iteration loop.

## Your Task

1. **Confirm cancellation** with the user
2. **Archive current state**:
   - Copy `.ralph/prd.json` to `.ralph/archive/{date}-{branch}/`
   - Copy `.ralph/progress.txt` to `.ralph/archive/{date}-{branch}/`
3. **Report final status**:
   - Tasks completed
   - Tasks remaining
   - Archive location

## Process

```bash
# Get branch name for archive
BRANCH=$(jq -r '.branchName' .ralph/prd.json 2>/dev/null || echo "unknown")
DATE=$(date '+%Y-%m-%d')
ARCHIVE_DIR=".ralph/archive/${DATE}-${BRANCH}"

# Create archive
mkdir -p "$ARCHIVE_DIR"
cp .ralph/prd.json "$ARCHIVE_DIR/"
cp .ralph/progress.txt "$ARCHIVE_DIR/" 2>/dev/null || true
cp .ralph/review-report.md "$ARCHIVE_DIR/" 2>/dev/null || true
cp -r .ralph/qa-scenarios "$ARCHIVE_DIR/" 2>/dev/null || true
cp .ralph/test_report.md "$ARCHIVE_DIR/" 2>/dev/null || true

echo "Archived to: $ARCHIVE_DIR"
```

## Output

```
## Ralph Pro Cancelled

**Project**: [project name]
**Branch**: [branch name]

### Final Status
- Completed: X/Y tasks
- Remaining: Z tasks
- QA: [enabled/disabled] — [N scenarios, M passed / not run]

### Archive Location
`.ralph/archive/{date}-{branch}/`

### Next Steps
- Review completed work on branch `{branch}`
- Run `/prd-init` to start a new feature
- Run `/ralph-pro` to resume (after checking PRD)
```

## If No Active Session

```
No active Ralph Pro session found.
```
