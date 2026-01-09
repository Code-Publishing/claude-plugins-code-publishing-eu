#!/bin/bash
# update-task-status.sh
# Updates a task's status in prd.json
# Usage: update-task-status.sh <task-id> <passes:true|false> [commit-hash]

set -e

TASK_ID="$1"
PASSES="$2"
COMMIT_HASH="${3:-null}"
PRD_FILE="${4:-.ralph/prd.json}"

if [[ -z "$TASK_ID" || -z "$PASSES" ]]; then
    echo "Usage: update-task-status.sh <task-id> <passes:true|false> [commit-hash] [prd-file]" >&2
    exit 1
fi

if [[ ! -f "$PRD_FILE" ]]; then
    echo "Error: PRD file not found at $PRD_FILE" >&2
    exit 1
fi

# Update the task
if [[ "$COMMIT_HASH" != "null" && -n "$COMMIT_HASH" ]]; then
    jq --arg id "$TASK_ID" --argjson passes "$PASSES" --arg hash "$COMMIT_HASH" '
        .userStories |= map(
            if .id == $id then
                .passes = $passes | .commitHash = $hash
            else
                .
            end
        )
    ' "$PRD_FILE" > "${PRD_FILE}.tmp" && mv "${PRD_FILE}.tmp" "$PRD_FILE"
else
    jq --arg id "$TASK_ID" --argjson passes "$PASSES" '
        .userStories |= map(
            if .id == $id then
                .passes = $passes
            else
                .
            end
        )
    ' "$PRD_FILE" > "${PRD_FILE}.tmp" && mv "${PRD_FILE}.tmp" "$PRD_FILE"
fi

echo "Task $TASK_ID updated: passes=$PASSES"
