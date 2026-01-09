#!/bin/bash
# archive-session.sh
# Archives the current Ralph Pro session
# Usage: archive-session.sh [prd-file] [progress-file]

set -e

PRD_FILE="${1:-.ralph/prd.json}"
PROGRESS_FILE="${2:-.ralph/progress.txt}"
RALPH_DIR="$(dirname "$PRD_FILE")"

if [[ ! -f "$PRD_FILE" ]]; then
    echo "No PRD file found at $PRD_FILE" >&2
    exit 1
fi

# Get branch name for archive folder
BRANCH=$(jq -r '.branchName // "unknown"' "$PRD_FILE" | tr '/' '-')
DATE=$(date '+%Y-%m-%d')
ARCHIVE_DIR="${RALPH_DIR}/archive/${DATE}-${BRANCH}"

# Create archive directory
mkdir -p "$ARCHIVE_DIR"

# Copy files
cp "$PRD_FILE" "$ARCHIVE_DIR/"
[[ -f "$PROGRESS_FILE" ]] && cp "$PROGRESS_FILE" "$ARCHIVE_DIR/"

# Report
echo "Session archived to: $ARCHIVE_DIR"

# Summary
TOTAL=$(jq '.userStories | length' "$PRD_FILE")
COMPLETED=$(jq '[.userStories[] | select(.passes == true)] | length' "$PRD_FILE")
echo "Tasks: $COMPLETED/$TOTAL completed"
