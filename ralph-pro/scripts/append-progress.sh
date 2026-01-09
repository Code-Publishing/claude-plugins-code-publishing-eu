#!/bin/bash
# append-progress.sh
# Appends a log entry to progress.txt
# Usage: append-progress.sh <task-id> <status> <message> [learnings]

set -e

TASK_ID="$1"
STATUS="$2"  # STARTED, COMPLETED, FAILED, SKIPPED
MESSAGE="$3"
LEARNINGS="${4:-}"
PROGRESS_FILE="${5:-.ralph/progress.txt}"

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Ensure progress file exists
if [[ ! -f "$PROGRESS_FILE" ]]; then
    mkdir -p "$(dirname "$PROGRESS_FILE")"
    cat > "$PROGRESS_FILE" << EOF
# Ralph Pro Progress Log
# Started: $TIMESTAMP
# ============================================

EOF
fi

# Append the entry
{
    echo "[$TIMESTAMP] [$STATUS] $TASK_ID: $MESSAGE"
    if [[ -n "$LEARNINGS" ]]; then
        echo "  Learnings: $LEARNINGS"
    fi
    echo ""
} >> "$PROGRESS_FILE"

echo "Progress logged: [$STATUS] $TASK_ID"
