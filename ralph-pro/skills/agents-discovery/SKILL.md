---
name: agents-discovery
description: Discover and load relevant AGENTS.md files from the project hierarchy. Use when you need project-specific guidance and conventions.
allowed-tools: Read, Glob, Bash(*)
---

# AGENTS.md Discovery

Discover and load project-specific guidance from AGENTS.md files.

## Overview

AGENTS.md files provide hierarchical documentation for AI agents:
- **Root AGENTS.md**: Project-wide conventions and patterns
- **Subfolder AGENTS.md**: Module-specific guidance

## When to Use

- At the start of any task to understand project conventions
- When working in a new area of the codebase
- When encountering unfamiliar patterns

## How It Works

1. Look for AGENTS.md in the current directory and all parent directories
2. Also check directories containing files you're modifying
3. Load content in order: root first, then more specific

## Discovery Process

```bash
# Find all AGENTS.md files
find . -name "AGENTS.md" -type f

# For relevant files based on git changes
./scripts/discover-agents.sh . content
```

## AGENTS.md Structure

Typical AGENTS.md contains:
- **Project Overview**: What this module/project does
- **Codebase Patterns**: "This module uses X for Y"
- **Gotchas**: "Do not forget to update Z when changing W"
- **Testing Approach**: How tests should be written
- **Dependencies**: Key relationships between modules

## Usage

When asked to discover AGENTS.md guidance:

1. Run the discovery script or manually find AGENTS.md files
2. Read and summarize the key points
3. Apply the guidance to your current task

## Example Output

```
Found AGENTS.md files:
- ./AGENTS.md (root)
- ./src/auth/AGENTS.md (auth module)

Key guidance:
- Use dependency injection for all services
- Tests must use the TestContainer fixture
- Auth module uses JWT with RS256 signing
```
