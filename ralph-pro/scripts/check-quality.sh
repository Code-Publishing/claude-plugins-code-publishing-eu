#!/bin/bash
# check-quality.sh
# Runs quality checks from prd.json
# Usage: check-quality.sh [prd-file]

set -e

PRD_FILE="${1:-.ralph/prd.json}"

if [[ ! -f "$PRD_FILE" ]]; then
    echo "No PRD file found at $PRD_FILE" >&2
    exit 1
fi

# Get quality checks
CHECKS=$(jq -r '.qualityChecks // [] | .[]' "$PRD_FILE")

if [[ -z "$CHECKS" ]]; then
    echo "No quality checks defined in PRD"
    exit 0
fi

echo "Running quality checks..."
echo "========================="

FAILED=0
while IFS= read -r cmd; do
    [[ -z "$cmd" ]] && continue

    echo ""
    echo "Running: $cmd"
    echo "---"

    if eval "$cmd"; then
        echo "✓ PASSED: $cmd"
    else
        echo "✗ FAILED: $cmd"
        FAILED=$((FAILED + 1))
    fi
done <<< "$CHECKS"

echo ""
echo "========================="
if [[ $FAILED -gt 0 ]]; then
    echo "Quality checks: $FAILED FAILED"
    exit 1
else
    echo "Quality checks: ALL PASSED"
    exit 0
fi
