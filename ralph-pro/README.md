# Ralph Pro

Advanced autonomous coding loop for Claude Code with PRD-based task queue, progress tracking, and CLAUDE.md hierarchical discovery.

## Features

- **PRD-based task queue**: Define features as user stories with acceptance criteria
- **Progress tracking**: Append-only learning log across iterations
- **CLAUDE.md discovery**: Hierarchical project guidance without context pollution
- **Fresh context per task**: Each task executes in a clean subagent context
- **One commit per task**: Clean git history with meaningful commits
- **Project-specific config**: Inherits CLAUDE.md, MCP servers, and quality checks

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
- `.ralph/prd.json` - Task queue with user stories
- `.ralph/progress.txt` - Learning log

### 2. Start the Loop

```bash
/ralph-pro
```

Options:
- `--max-iterations 20` - Safety limit (default: 10)
- `--quality-checks "npm test"` - Override quality checks

### 3. Check Progress

```bash
/progress-check
```

### 4. Cancel if Needed

```bash
/cancel-ralph
```

## Architecture

```
Parent Session (orchestrator)
├── Tracks: prd.json, progress.txt, iteration count
├── Spawns: Subagent per task with context: fork
└── Loop: Until all tasks pass or max iterations

Subagent (task-executor)
├── Fresh context: CLAUDE.md loaded automatically by Claude Code
├── Works: Implements single user story
├── Updates: Creates/updates CLAUDE.md with discovered patterns
├── Returns: Completion status + learnings
└── Exits: Parent captures result, commits changes
```

## PRD Format

```json
{
  "project": "user-authentication",
  "branchName": "feature/user-auth",
  "description": "Implement user authentication with JWT",
  "qualityChecks": [
    "npm test",
    "npm run lint"
  ],
  "userStories": [
    {
      "id": "US-001",
      "title": "User registration endpoint",
      "description": "As a user, I want to register so that I can create an account",
      "acceptanceCriteria": [
        "POST /auth/register accepts email and password",
        "Returns 201 with user ID on success"
      ],
      "priority": 1,
      "passes": false,
      "commitHash": null,
      "notes": ""
    }
  ]
}
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

Claude Code automatically loads relevant CLAUDE.md files when working in those directories. The task-executor agent is instructed to create/update CLAUDE.md files when discovering reusable patterns during implementation.

Example `CLAUDE.md`:

```markdown
# CLAUDE.md - Auth Module

## Patterns
- Use bcrypt for password hashing
- JWT tokens expire after 24 hours

## Gotchas
- Always validate email format before database insert
- Remember to hash password before storing

## Testing
- Use TestContainer for database tests
- Mock JWT signing in unit tests
```

## File Lifecycles

| File | Lifecycle | Behavior |
|------|-----------|----------|
| `CLAUDE.md` | Project lifetime | Never reset, accumulates patterns |
| `prd.json` | Loop duration | Reset when new loop starts |
| `progress.txt` | Loop duration | Archived when loop completes |

Archives are stored in `.ralph/archive/{date}-{branch}/`.

## Comparison with Ralph Wiggum

| Feature | Ralph Wiggum | Ralph Pro |
|---------|--------------|-----------|
| Task queue | Single prompt | PRD with user stories |
| Progress log | None | Append-only progress.txt |
| Context | Same session | Fresh per task (subagent) |
| CLAUDE.md updates | None | Auto-updates with patterns |
| Commits | User-controlled | Automatic per task |

## Commands

| Command | Description |
|---------|-------------|
| `/prd-init <description>` | Create new PRD from description |
| `/ralph-pro [options]` | Start iteration loop |
| `/progress-check` | Show current status |
| `/cancel-ralph` | Cancel and archive |

## Skills

| Skill | Description |
|-------|-------------|
| `task-executor` | Executes single user story (context: fork) |

## Scripts

| Script | Description |
|--------|-------------|
| `select-next-task.sh` | Get highest priority pending task |
| `update-task-status.sh` | Update task completion status |
| `append-progress.sh` | Log entry to progress.txt |
| `check-quality.sh` | Run quality check commands |
| `archive-session.sh` | Archive completed session |

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
