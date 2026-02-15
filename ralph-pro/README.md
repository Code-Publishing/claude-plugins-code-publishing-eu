# Ralph Pro

Advanced autonomous coding loop for Claude Code with PRD-based task queue, architecture-driven execution, progress tracking, and CLAUDE.md hierarchical discovery.

## Features

- **PRD-based task queue**: Define features as user stories with acceptance criteria
- **Architecture-driven execution**: Each story gets a detailed spec with approach, constraints, and implementation steps
- **Opus constitution guardrails**: Prevent the executor from simplifying or deviating from the architecture
- **Split structure**: Lean status tracker (`prd.json`) + per-story specs (`PRD-US-XXX.md`)
- **Progress tracking**: Append-only learning log across iterations
- **CLAUDE.md discovery**: Hierarchical project guidance without context pollution
- **Fresh context per task**: Each task executes in a clean subagent context
- **One commit per task**: Clean git history with meaningful commits
- **Configurable executor model**: Use `--model` to choose sonnet, opus, or haiku

## Installation

```bash
# Clone the plugin
git clone https://github.com/sotomski/ralph-pro.git

# Use with Claude Code
claude --plugin-dir /path/to/ralph-pro
```

Or add to your project's `.claude/plugins/`:
```bash
cd your-project
mkdir -p .claude/plugins
git clone https://github.com/sotomski/ralph-pro.git .claude/plugins/ralph-pro
```

## Quick Start

### 1. Initialize a PRD

```bash
/prd-init "Build user authentication with JWT tokens"
```

This creates:
- `.ralph/prd.json` — Lean status tracker (project overview + story statuses)
- `.ralph/stories/PRD-US-XXX.md` — Per-story specs with architecture
- `.ralph/progress.txt` — Learning log

### 2. Start the Loop

```bash
/ralph-pro
```

Options:
- `--max-iterations 20` — Safety limit (default: 10)
- `--prd-file path` — Custom PRD location (default: .ralph/prd.json)
- `--model opus` — Override executor model (default: sonnet)

### 3. Check Progress

```bash
/progress-check
```

### 4. Cancel if Needed

```bash
/cancel-ralph
```

## Architecture

### Split Structure

```
.ralph/
├── prd.json                  # Lean: project overview + story status list
├── stories/
│   ├── PRD-US-001.md         # Full story spec + architecture
│   ├── PRD-US-002.md
│   └── ...
├── progress.txt              # Append-only learning log
└── archive/
    └── {date}-{branch}/      # Archived sessions
```

### Two-Phase PRD Initialization

**Phase 1 — Story Decomposition**: Parse user's feature, ask clarifying questions, generate user story list, detect project language.

**Phase 2 — Architecture Derivation**: Explore the codebase, discover patterns and conventions, create detailed per-story spec files with architecture, context files, constraints, and implementation steps.

### Execution Model

```
Parent Session (orchestrator)
├── Reads: prd.json (lean status)
├── Selects: Next pending story
├── Passes: Story file path (PRD-US-XXX.md) to executor
└── Loop: Until all tasks pass or max iterations

Subagent (task-executor)
├── Reads: Story spec with architecture
├── Reads: Context files listed in spec
├── Follows: Implementation steps exactly
├── Commits: One commit per story
└── Reports: COMPLETE | INCOMPLETE | BLOCKED
```

## PRD Format (Lean)

The main `prd.json` is a lean status tracker — all detailed descriptions and architecture live in the story files:

```json
{
  "project": "user-authentication",
  "branchName": "feature/user-auth",
  "description": "Implement user authentication with JWT",
  "language": "typescript",
  "qualityChecks": ["npm test", "npm run lint"],
  "userStories": [
    { "id": "US-001", "title": "User registration endpoint", "priority": 1, "passes": false, "commitHash": null },
    { "id": "US-002", "title": "User login endpoint", "priority": 2, "passes": false, "commitHash": null }
  ]
}
```

## Story Spec Format

Each `PRD-US-XXX.md` contains the full specification:

```markdown
# US-001: User registration endpoint

## Description
As a new user, I want to register with email and password...

## Acceptance Criteria
- POST /auth/register accepts email and password
- Returns 201 with user ID on success

## Context Files (Read These First)
- `src/services/UserService.ts` — existing service pattern
- `src/routes/users.ts` — existing route pattern

## Architecture
### Approach / Rationale / Files / Constraints / Steps / Tests / Types
```

## CLAUDE.md Pattern

Create `CLAUDE.md` files in your project for hierarchical guidance:

```
project-root/
├── CLAUDE.md              # Project-wide patterns
└── src/
    └── auth/
        └── CLAUDE.md      # Auth-specific guidance
```

Claude Code automatically loads relevant CLAUDE.md files when working in those directories. The task-executor agent creates/updates CLAUDE.md files when discovering reusable patterns during implementation.

## File Lifecycles

| File | Lifecycle | Behavior |
|------|-----------|----------|
| `CLAUDE.md` | Project lifetime | Never reset, accumulates patterns |
| `prd.json` | Loop duration | Reset when new loop starts |
| `stories/` | Loop duration | Archived when loop completes |
| `progress.txt` | Loop duration | Archived when loop completes |

Archives are stored in `.ralph/archive/{date}-{branch}/`.

## Comparison with Ralph Wiggum

| Feature | Ralph Wiggum | Ralph Pro |
|---------|--------------|-----------|
| Task queue | Single prompt | PRD with user stories |
| Architecture | None | Per-story specs with constraints |
| Progress log | None | Append-only progress.txt |
| Context | Same session | Fresh per task (subagent) |
| CLAUDE.md updates | None | Auto-updates with patterns |
| Commits | User-controlled | Automatic per task |
| Model config | Fixed | Configurable via --model |

## Commands

| Command | Description |
|---------|-------------|
| `/prd-init <description>` | Create new PRD with architecture specs |
| `/ralph-pro [options]` | Start iteration loop |
| `/progress-check` | Show current status |
| `/cancel-ralph` | Cancel and archive |

## Skills

| Skill | Description |
|-------|-------------|
| `task-executor` | Executes single user story following architecture spec (context: fork) |

## Scripts

| Script | Description |
|--------|-------------|
| `select-next-task.sh` | Get highest priority pending task |
| `update-task-status.sh` | Update task completion status |
| `append-progress.sh` | Log entry to progress.txt |
| `check-quality.sh` | Run quality check commands |
| `archive-session.sh` | Archive completed session (incl. stories/) |

## Project Integration

Ralph Pro inherits your project's configuration:

- **CLAUDE.md**: Project instructions (e.g., "Use fvm in the project")
- **MCP servers**: Custom tools from `.mcp.json`
- **Quality checks**: Define in PRD or pass via `--quality-checks`

Example for Flutter project:
```json
{
  "qualityChecks": [
    "fvm flutter analyze",
    "fvm flutter test"
  ]
}
```

## License

MIT

## Credits

Inspired by:
- [Ralph](https://github.com/snarktank/ralph) - Original Ampcode automation
- [Ralph Wiggum](https://github.com/anthropics/claude-code/tree/main/plugins/ralph-wiggum) - Official Claude Code plugin
- [Compound Engineering](https://github.com/EveryInc/compound-engineering-plugin) - CLAUDE.md pattern
