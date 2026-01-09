#!/bin/bash
# discover-agents.sh
# Discovers and concatenates relevant AGENTS.md files
# Traverses from modified files up to root, collecting unique AGENTS.md files

set -e

PROJECT_ROOT="${1:-.}"
OUTPUT_MODE="${2:-content}"  # content or paths

# Find all AGENTS.md files from root down
find_all_agents() {
    find "$PROJECT_ROOT" -name "AGENTS.md" -type f 2>/dev/null | sort
}

# Get AGENTS.md files relevant to recently modified files
find_relevant_agents() {
    local agents_files=()

    # Get modified files from git
    local modified_files
    modified_files=$(git diff --name-only HEAD 2>/dev/null || true)
    modified_files+=$'\n'$(git diff --name-only --cached 2>/dev/null || true)
    modified_files+=$'\n'$(git ls-files --others --exclude-standard 2>/dev/null || true)

    # Always include root AGENTS.md if it exists
    if [[ -f "$PROJECT_ROOT/AGENTS.md" ]]; then
        agents_files+=("$PROJECT_ROOT/AGENTS.md")
    fi

    # For each modified file, traverse up to find AGENTS.md
    while IFS= read -r file; do
        [[ -z "$file" ]] && continue

        local dir
        dir=$(dirname "$file")

        while [[ "$dir" != "." && "$dir" != "/" ]]; do
            local agents_path="$PROJECT_ROOT/$dir/AGENTS.md"
            if [[ -f "$agents_path" ]]; then
                # Add if not already in list
                local found=false
                for existing in "${agents_files[@]}"; do
                    [[ "$existing" == "$agents_path" ]] && found=true && break
                done
                $found || agents_files+=("$agents_path")
            fi
            dir=$(dirname "$dir")
        done
    done <<< "$modified_files"

    printf '%s\n' "${agents_files[@]}"
}

# Main logic
case "$OUTPUT_MODE" in
    paths)
        find_relevant_agents
        ;;
    all-paths)
        find_all_agents
        ;;
    content)
        # Output concatenated content with headers
        while IFS= read -r agents_file; do
            [[ -z "$agents_file" ]] && continue
            echo "# ============================================"
            echo "# From: $agents_file"
            echo "# ============================================"
            echo ""
            cat "$agents_file"
            echo ""
            echo ""
        done < <(find_relevant_agents)
        ;;
    *)
        echo "Usage: discover-agents.sh [project-root] [content|paths|all-paths]" >&2
        exit 1
        ;;
esac
