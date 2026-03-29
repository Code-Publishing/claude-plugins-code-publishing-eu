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

### 99bottles-oop-handbook

An OOP development methodology plugin for Claude Code based on Sandi Metz's *99 Bottles of OOP* and Uncle Bob's *Clean Architecture*.

**Install:**
```bash
/plugin install 99bottles-oop-handbook@claude-code-publishing-eu
```

**Features:**
- Teaches object-oriented coding through incremental, evidence-based refactoring
- Shameless Green approach for starting new features
- Flocking Rules for step-by-step refactoring
- Class extraction patterns
- Replacing conditionals with polymorphism
- Clean Architecture principles
- Anti-patterns specific to AI agents

**Commands:**
- `/99-new-feature` - Start a new feature using TDD + Shameless Green
- `/99-refactor` - Refactor existing code using the Flocking Rules
- `/99-review` - Review code against handbook principles

See [99bottles-oop-handbook/README.md](99bottles-oop-handbook/README.md) for full documentation.

## License

MIT
