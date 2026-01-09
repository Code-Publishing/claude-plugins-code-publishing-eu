#!/bin/bash
# inject-agents-context.sh
# Hook script for UserPromptSubmit - injects relevant AGENTS.md content
# This script is called by the UserPromptSubmit hook

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if AGENTS.md discovery should run
# Skip if no AGENTS.md files exist in project
if ! find . -name "AGENTS.md" -type f -print -quit 2>/dev/null | grep -q .; then
    exit 0
fi

# Discover and output relevant AGENTS.md content
AGENTS_CONTENT=$("$SCRIPT_DIR/discover-agents.sh" "." "content" 2>/dev/null || true)

if [[ -n "$AGENTS_CONTENT" ]]; then
    # Output as JSON for hook consumption
    cat << EOF
{
  "type": "prompt",
  "prompt": "## AGENTS.md Context (auto-injected)\n\nThe following project-specific guidance was discovered from AGENTS.md files:\n\n$AGENTS_CONTENT"
}
EOF
fi
