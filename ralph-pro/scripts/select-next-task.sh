#!/bin/bash
# select-next-task.sh
# Selects the highest priority pending task from prd.json
# Outputs the task as JSON to stdout

set -e

PRD_FILE="${1:-.ralph/prd.json}"

if [[ ! -f "$PRD_FILE" ]]; then
    echo "Error: PRD file not found at $PRD_FILE" >&2
    exit 1
fi

# Find the first task with passes: false, ordered by priority
NEXT_TASK=$(jq -r '
    .userStories
    | sort_by(.priority)
    | map(select(.passes == false))
    | first
    // empty
' "$PRD_FILE")

if [[ -z "$NEXT_TASK" || "$NEXT_TASK" == "null" ]]; then
    echo "ALL_COMPLETE"
    exit 0
fi

echo "$NEXT_TASK"
