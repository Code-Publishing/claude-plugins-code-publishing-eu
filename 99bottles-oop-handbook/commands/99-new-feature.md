---
description: Start a new feature using Shameless Green + TDD methodology
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep]
---

# /99-new-feature — Start a New Feature

Read the following reference files from the oop-development-handbook skill
before proceeding:
- `skills/oop-development-handbook/references/shameless-green.md`
- `skills/oop-development-handbook/references/anti-patterns.md`

Then follow this procedure:

## 1. Clarify the requirement

Before writing any code, state what the feature does in one sentence.
Identify the inputs and expected outputs. If anything is unclear, ask.

## 2. Write a failing test for the simplest case

Pick the most basic, most common scenario. Write a test that specifies
expected behavior. Run the test. Confirm it fails.

## 3. Shameless Green

Make the test pass with the simplest possible code. Do NOT:
- Extract a helper method "for later"
- Create a class hierarchy
- Add parameters "for flexibility"
- Introduce a design pattern

## 4. Next test, next case

Write the next simplest test case. Make it pass. Add branches,
conditionals, or case statements as needed. Duplication is fine.

## 5. Repeat until all cases pass

Continue until the feature's behavior is complete. You now have a
collection of concrete examples.

## 6. Examine for smells

Look at the code:
- Switch/case with many branches? → Consider refactoring (use /99-refactor)
- Data traveling together? → Consider a value object
- Blank line splitting a method? → Two responsibilities
- Repeated structure with small variations? → Hidden concept

If smells are mild and no new requirement is pending, stop. Ship it.

## 7. Check architectural placement

- Is domain logic in a domain object (not a controller/handler)?
- Does the domain object import any framework code?
- If yes to the second question, extract a boundary
  (read `skills/oop-development-handbook/references/clean-architecture-layers.md`).

## Rules during this entire process

- Run tests after every change.
- Never refactor and add behavior simultaneously.
- If tests go red unexpectedly, undo and make a smaller change.
- Resist the urge to "clean up" unrelated code.
