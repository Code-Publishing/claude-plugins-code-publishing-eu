---
description: Refactor existing code using the Flocking Rules methodology
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep]
---

# /99-refactor — Refactor Existing Code

Read the following reference files from the oop-development-handbook skill
before proceeding:
- `skills/oop-development-handbook/references/flocking-rules.md`
- `skills/oop-development-handbook/references/extract-class.md`
- `skills/oop-development-handbook/references/replace-conditional.md`
- `skills/oop-development-handbook/references/anti-patterns.md`

Then follow this procedure:

## 1. Identify the trigger

State why you are refactoring. Valid triggers:
- A new requirement has arrived that the current structure resists.
- A specific code smell makes the code hard to read or change.
- Tests are difficult to write because of structural coupling.

Invalid triggers:
- "This could be cleaner" (too vague)
- "I think we'll need this to be flexible" (speculation)
- "This isn't how I'd write it" (preference, not need)

Name the specific smell or requirement driving the refactoring.

## 2. Verify green baseline

Run all tests. If any test is red, fix the failing test first. Never
refactor from a red baseline.

## 3. Apply the Flocking Rules

1. Select the things that are most alike.
2. Find the smallest difference between them.
3. Make the simplest change to remove that difference:
   a. Parse the new code (add it, don't call it)
   b. Parse and execute it (call it, don't use the result)
   c. Parse, execute, and use the result
   d. Delete unused old code

After EACH sub-step: run the tests. If red, undo immediately.

## 4. Reach a stable landing point

After removing one difference, pause. The code should:
- Pass all tests
- Be internally consistent
- Be shippable as-is

Assess: is the smell resolved? Is the code open to the pending
requirement? If yes, stop. If no, go back to step 3.

## 5. Consider extraction (if warranted)

If the Flocking Rules have revealed a hidden concept with 3+ concrete
examples, consider extracting a class. Follow the decision flowchart
in `references/extract-class.md`.

If a conditional has grown and polymorphism makes sense, follow
`references/replace-conditional.md`.

## 6. Do NOT exceed scope

Refactor only what's needed for the current trigger. Note other
improvements for separate sessions. Do not combine unrelated
refactorings.

## Discipline reminders

- Change one line at a time.
- Run tests after every change.
- Undo if red — do not debug forward.
- Refactoring changes structure, not behavior. If behavior needs to
  change, finish the refactoring first, then add behavior in a
  separate step.
- Do not rename and restructure simultaneously.
