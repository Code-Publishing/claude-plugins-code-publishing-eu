# The Flocking Rules — Step-by-Step Refactoring

## The Three Rules

1. **Select the things that are most alike.**
2. **Find the smallest difference between them.**
3. **Make the simplest change to remove that difference.**

"Simplest change" follows this sequence:
  a. Parse the new code (write it, but don't call it).
  b. Parse and execute it (call it, but don't use the result).
  c. Parse, execute, and use its result (replace the old code).
  d. Delete the unused old code.

## Discipline During Refactoring

These are not optional. These are not "for beginners." This discipline
is what prevents you from introducing bugs during structural changes.

- **Change only one line at a time.**
- **Run the tests after every change.**
- **If tests go red, undo immediately** and make a smaller change.
- **Do not refactor and change behavior simultaneously.** Pick one.
  Finish it. Then do the other.

## The Full Procedure

### Phase 1: Identify the target

Look at the code. Find the things that are most alike. In a case/switch
statement, this means the branches. In duplicated methods, this means
the methods. In repeated code blocks, this means the blocks.

Choose the two most similar things. You will make them identical, then
collapse them.

### Phase 2: Work across the smallest difference

Compare your two chosen things line by line. Find the first point where
they differ. This is your target. You will make this one difference
disappear.

### Phase 3: Create an empty method

If the difference needs a name (which it usually does), create an empty
method for that concept. Run the tests. Green confirms the new method
is syntactically correct (rule 3a: parse).

### Phase 4: Implement the method for the default case

Fill the method with the logic for the most common case (usually the
`else` branch). Run the tests. Green means the method works (rule 3b:
parse and execute — but it's not being called from the target yet).

### Phase 5: Use the method in one place

Replace the hardcoded value in ONE branch with a call to the new method.
Run the tests. Green means the method returns the correct value for
this case (rule 3c: parse, execute, and use result).

### Phase 6: Handle the remaining case

If the method needs to handle multiple cases (e.g., "bottle" vs.
"bottles"), add a parameter. Use the Gradual Cutover technique:

1. Add the parameter with a conspicuous default: `(number = :FIXME)`
   or `(number = "FIXME")` or `(int number = -999)`.
2. Add the conditional logic inside the method.
3. Update the first caller to pass the real argument. Run tests.
4. Update the second caller. Run tests.
5. Once all callers pass the real argument, remove the default.

### Phase 7: Make the branches identical

After both branches use the same method call, the branches should now
be identical. When two branches of a conditional are identical, delete
one and remove the conditional. Run the tests.

### Phase 8: Repeat

Go back to Phase 1. Find the next smallest difference. Repeat until
the code has no more duplication to resolve, or until the smell you
started with is gone.

## Gradual Cutover Refactoring

When changing a method signature used by multiple callers:

1. Add the new parameter with a default that is obviously wrong
   (`:FIXME`, `"TODO"`, `-1`, `null`). This is a temporary shim.
2. Update the method body to handle the new parameter.
3. Migrate callers one at a time, running tests after each.
4. Once all callers pass the real argument, remove the default.

The conspicuous default serves two purposes:
- It keeps the code deployable at every step.
- It reminds you (and future readers) that the default must be removed.

## Stable Landing Points

After each application of the Flocking Rules, the code should be in a
stable state: all tests pass, the code is internally consistent, and
it could be shipped as-is. These are "stable landing points."

Think of it like crossing a river on stepping stones. Each stone is a
place you can stand safely. You don't jump from one bank to the other.

If you find yourself in a state where multiple things are broken
simultaneously, you've taken too large a step. Undo and break the
change into smaller pieces.

## When to Stop Refactoring

Stop when:
- The smell that triggered the refactoring is gone.
- The code is open to the pending requirement.
- Further refactoring would be speculative (no concrete need).

Do not refactor past the point of necessity. Over-refactored code is
as problematic as under-refactored code — it contains abstractions
that exist "just in case."
