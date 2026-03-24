# 99 Bottles OOP Handbook

An OOP development methodology plugin for Claude Code based on Sandi Metz's
*99 Bottles of OOP* and Uncle Bob's *Clean Architecture*.

## What It Does

This plugin teaches your AI coding agent to write object-oriented code using
incremental, evidence-based refactoring — not speculative abstraction.

**Process:** Sandi Metz's methodology — Shameless Green, Flocking Rules,
gradual extraction, polymorphism through refactoring.

**Direction:** Uncle Bob's Clean Architecture — dependencies point inward,
domain logic stays pure, layers emerge from need.

## Components

### Skill: `oop-development-handbook`

Background knowledge that Claude loads automatically when it detects OOP
coding tasks. Contains core principles and routes to detailed reference
files on demand. Covers:

- Shameless Green (starting new features)
- Flocking Rules (step-by-step refactoring)
- Class extraction (when and how)
- Replacing conditionals with polymorphism
- Clean Architecture layers
- Anti-patterns specific to AI agents

### Commands

| Command | Purpose |
|---------|---------|
| `/99-new-feature` | Start a new feature using TDD + Shameless Green |
| `/99-refactor` | Refactor existing code using the Flocking Rules |
| `/99-review` | Review code against handbook principles |

## Installation

```bash
/plugin install 99bottles-oop-handbook@claude-code-publishing-eu
```

## Recommended: CLAUDE.md Companion

For maximum effect, add these lines to your project or global `CLAUDE.md`
so the core rules are always in context (not just when the skill triggers):

```markdown
## OOP Methodology (non-negotiable)

- Start every new feature with Shameless Green: the simplest code that
  passes all tests. No premature abstractions.
- Do not extract a class, interface, or pattern until you have 3+
  concrete examples AND can name the concept in domain terms.
- Prefer duplication over the wrong abstraction.
- Refactor using the Flocking Rules: find alike things, find the smallest
  difference, remove it with the simplest change. One line at a time.
  Tests after every change. Undo if red.
- Never refactor and change behavior in the same step.
- Dependencies point inward: domain objects must never import framework
  or infrastructure code.
- When working on existing code, assume complexity exists for a reason.
  Do not simplify what you don't understand. Ask if unsure.
- Use /99-new-feature, /99-refactor, /99-review for guided workflows.
```

## Philosophy

> "Make the change easy (warning: this may be hard), then make the easy
> change." — Kent Beck

This plugin fights the most common AI coding failure mode: jumping to
abstractions before understanding the problem. It enforces a discipline
of small, safe, test-verified steps that arrive at good design through
evidence rather than imagination.

## License

MIT
