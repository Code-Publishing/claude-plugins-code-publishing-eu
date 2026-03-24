---
name: oop-development-handbook
description: >
  Development methodology governing how the agent writes, refactors, and
  architects object-oriented code. This skill defines the agent's programming
  process: incremental Metz-style refactoring as the method, Clean Architecture
  as the directional goal. Trigger on EVERY coding task involving OOP code —
  new features, bug fixes, refactors, architecture decisions, class design,
  and code review. Also trigger when the agent is tempted to extract
  abstractions, create class hierarchies, introduce design patterns, or
  restructure existing code. Trigger when the user mentions refactoring,
  code smells, design patterns, SOLID principles, polymorphism, class
  extraction, dependency injection, or architecture layers. If in doubt
  whether this skill applies to a coding task, it applies.
user-invocable: false
---

# OOP Development Handbook

This handbook defines how you write and evolve object-oriented code.
It is not advisory — it is your operating procedure. Follow it on every
coding task.

Two pillars:

1. **Process → Sandi Metz's incremental, evidence-based refactoring.**
   You arrive at good design through small, safe, test-verified steps.
   You do not guess the final shape upfront.

2. **Direction → Uncle Bob's Clean Architecture.**
   Dependencies point inward. Business rules don't know about frameworks,
   databases, or UI. This is the horizon you refactor *toward*, not a
   blueprint you impose on day one.

---

## Non-Negotiable Principles

These override your defaults. When instinct conflicts with a principle
below, the principle wins.

### 1. Shameless Green First

When solving a new problem, produce the simplest code that passes all
tests — even if it contains duplication, uses conditionals, or looks
unsophisticated. This is honest code that reflects what you know now,
without speculating about what you might need later.

→ For the full procedure: read `references/shameless-green.md`

### 2. Resist Premature Abstraction

The wrong abstraction is more damaging than duplication. Do not extract
an abstraction until you have 3+ concrete examples that share a visible
pattern AND you can name the concept in domain terms.

→ Decision flowchart and detailed guidance: `references/extract-class.md`

### 3. Refactor Mechanically, Not Intuitively

Follow the Flocking Rules: select the most alike things, find the
smallest difference, make the simplest change to remove it. Change one
line at a time. Run tests after every change. Undo if red.

→ Full procedure with examples: `references/flocking-rules.md`

### 4. Dependencies Point Inward

Domain/business logic depends on nothing external. Use cases depend on
domain objects, not frameworks. Adapters depend on use cases, never the
reverse. This is the one architectural constraint you maintain from the
start.

→ Layer definitions and when to introduce them: `references/clean-architecture-layers.md`

### 5. Replace Conditionals With Polymorphism — When Ready

Start with a conditional (Shameless Green). When a new requirement makes
the conditional grow, refactor: extract a class hierarchy, introduce a
factory. Now the new requirement is just a new subclass.

→ Step-by-step playbook: `references/replace-conditional.md`

### 6. Never Simplify What You Don't Understand

When working on existing code in autonomous mode, assume complexity
exists for a reason. Do not flatten hierarchies, remove edge-case
handling, or merge distinct domain concepts without understanding why
they exist. If you cannot determine the reason, ask.

→ Full list of failure modes: `references/anti-patterns.md`

---

## Priority Ranking

When principles conflict, higher-ranked ones win:

1. **Tests stay green.** No change is acceptable if it breaks tests.
2. **Don't violate the dependency rule.** Domain must not import framework.
3. **Prefer duplication over the wrong abstraction.**
4. **Change one thing at a time.** Refactor or add behavior, never both.
5. **Name things after domain concepts, not implementation.**
6. **Code is read far more often than written.** Optimize for the reader.
7. **Make the change easy, then make the easy change.**

---

## Slash Commands

This handbook provides three entry-point commands for specific workflows.
Each loads the relevant reference files and walks you through the
procedure:

- `/99-new-feature` — Start a new feature using Shameless Green + TDD.
- `/99-refactor` — Refactor existing code using Flocking Rules.
- `/99-review` — Review code against handbook principles.

---

## Reference Files

Read these on demand when you need detailed procedures. Do not load them
all at once — use progressive disclosure.

| File | When to read |
|------|-------------|
| `references/shameless-green.md` | Starting a new feature or solving a new problem |
| `references/flocking-rules.md` | Refactoring existing code step by step |
| `references/extract-class.md` | Considering whether to extract a class or abstraction |
| `references/replace-conditional.md` | A conditional is growing and you're considering polymorphism |
| `references/clean-architecture-layers.md` | Making architecture decisions, placing code in layers |
| `references/anti-patterns.md` | Autonomous mode, or any time you're about to simplify/restructure |
