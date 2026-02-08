# Claude Plugins - Code Publishing EU

A marketplace of Claude Code plugins by Code Publishing EU.

## Installation

Add this marketplace to Claude Code:

```bash
/plugin marketplace add https://github.com/code-publishing-eu/claude-plugins-code-publishing-eu
```

Or configure in `~/.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "code-publishing-eu": {
      "source": {
        "source": "github",
        "repo": "code-publishing-eu/claude-plugins-code-publishing-eu"
      }
    }
  }
}
```

## Available Plugins

### ralph-pro

Advanced autonomous coding loop with PRD-based task queue, progress tracking, and CLAUDE.md hierarchical discovery.

**Install:**
```bash
/plugin install ralph-pro@code-publishing-eu
```

**Features:**
- PRD-based task queue with user stories and acceptance criteria
- Progress tracking with append-only learning log
- CLAUDE.md hierarchical discovery for context-efficient guidance
- Fresh context per task via subagent
- One commit per completed task
- Project-specific quality checks

**Commands:**
- `/prd-init` - Initialize a PRD from description
- `/ralph-pro` - Start iteration loop
- `/progress-check` - Check progress status
- `/cancel-ralph` - Cancel and archive

See [ralph-pro/README.md](ralph-pro/README.md) for full documentation.

## License

MIT
