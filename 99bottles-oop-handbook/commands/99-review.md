---
description: Review code against OOP handbook principles (architecture, smells, abstractions)
allowed-tools: [Read, Glob, Grep]
---

# /99-review — Review Code Against Handbook Principles

Read the following reference files from the oop-development-handbook skill
before proceeding:
- `skills/oop-development-handbook/references/anti-patterns.md`
- `skills/oop-development-handbook/references/clean-architecture-layers.md`
- `skills/oop-development-handbook/references/extract-class.md`

Then review the code (specified by the user, or the most recently changed
files) against the following checklist. Report findings grouped by severity.

---

## Checklist

### Critical (must fix before shipping)

- [ ] **Tests exist and pass.** Is the code under test? Do the tests
      verify behavior (not implementation)?
- [ ] **Dependency rule respected.** Does any domain/entity class import
      a framework, database driver, or infrastructure library? If yes,
      this is a boundary violation.
- [ ] **No behavior + refactor combo.** Were structural changes and new
      behavior introduced in the same change? If yes, they should be
      separated.

### Important (should fix soon)

- [ ] **Wrong abstraction detection.** Is there an abstraction (base
      class, interface, generic) with only one concrete implementation?
      If yes, is there a concrete reason for it, or is it speculative?
- [ ] **Premature extraction.** Are there classes or methods that exist
      "for flexibility" but aren't used by more than one caller? If yes,
      consider inlining until a second use appears.
- [ ] **Simplification collapse.** Has existing complexity been removed
      without verifying the reason for that complexity? Check: are there
      tests covering the removed edge cases?
- [ ] **Names reflect domain.** Do class and method names describe domain
      concepts, or implementation mechanisms? Watch for: Manager, Helper,
      Processor, Handler, Utils.
- [ ] **Liskov compliance.** If there's a class hierarchy, can every
      subclass be used in place of the base class? Do overridden methods
      return compatible types?

### Advisory (consider for future improvement)

- [ ] **Code smells present.** Are there:
  - Switch/case with 3+ branches? → Candidate for polymorphism
  - Data clumps (groups of data traveling together)? → Candidate for
    value object
  - Feature envy (method uses another class's data more than its own)?
    → Candidate for moving
  - Blank lines splitting a method? → Two responsibilities
- [ ] **Duplication across boundaries.** Is duplicated code being
      extracted into a shared utility across layers? This may introduce
      harmful coupling.
- [ ] **Pattern count.** Were multiple design patterns introduced in one
      change? Each pattern should be a separate refactoring step.
- [ ] **Factory complexity.** If there's a factory, is it the simplest
      style that works? (Hard-coded conditional → hash lookup →
      self-registering objects. Start simple.)
- [ ] **Immutability.** Are new classes mutable when they don't need to
      be? Prefer setting all data in the constructor with no setters.

---

## Reporting Format

For each finding, report:

1. **What:** The specific issue, with file and line reference.
2. **Why:** Why this matters (referencing the relevant handbook principle).
3. **Suggestion:** What to do about it (including "leave it for now" if
   the issue is minor and no requirement is forcing change).

Do not suggest refactorings that aren't driven by a concrete need.
Flag them as advisory observations, not action items.
