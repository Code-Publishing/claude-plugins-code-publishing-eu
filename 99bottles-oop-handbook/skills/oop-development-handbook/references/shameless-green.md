# Shameless Green — Starting New Features

## What Is Shameless Green?

Shameless Green is the simplest solution that passes all tests. It is
concrete, possibly duplicated, and deliberately unsophisticated. It is
not lazy code — it is *honest* code that reflects exactly what you know
right now.

The name comes from the test runner: you want green (passing) tests, and
you are shameless about how simple the code looks to achieve it.

## Why Start Here?

- You cannot create the right abstraction until you fully understand the
  problem. Shameless Green gives you concrete examples to reason from.
- Early abstractions are almost always wrong. Wrong abstractions create
  a catch-22: they prevent you from seeing the right abstraction.
- Simple code is easy to change later. Clever code is not.
- Duplication in Shameless Green is *useful* — each duplicate supplies
  an independent example of a concept you don't yet understand.

## The Procedure

### Step 1: Write a failing test for the simplest case

Pick the most basic, most common scenario. Write a test that specifies
the expected output. Run the test. Confirm it fails.

### Step 2: Make it pass with the simplest possible code

Write the minimum code to make the test green. This might be a literal
return value, a single conditional, or a hardcoded string. That's fine.

Do NOT:
- Extract a helper method "for later"
- Create a class hierarchy
- Add parameters "for flexibility"
- Introduce a pattern you think you'll need

### Step 3: Write the next test

Pick the next simplest case. Often this means a different variant of the
same behavior. Write the test. Run it. Confirm it fails.

### Step 4: Make it pass

Add the minimum code. If this means adding a branch to a conditional,
add the branch. If it means adding a case to a case/switch/when
statement, add the case. Duplication is fine at this stage.

### Step 5: Repeat until all cases pass

Continue adding tests and making them pass. You are building up a
collection of concrete examples. Each example teaches you something
about the problem.

### Step 6: Examine the code for smells

Now that all cases pass, look at the code. Do you see:
- A switch/case with many branches? (Switch Statement smell)
- Groups of data traveling together? (Data Clump smell)
- A method doing two things separated by a blank line? (Two responsibilities)
- The same structure repeated with small variations? (Duplication that
  might point to a hidden concept)

If you see smells, proceed to refactoring (see `flocking-rules.md`).
If the code is clean and simple, stop. You're done.

### Step 7: Check architectural placement

After refactoring, verify that the code respects the dependency rule:
- Domain logic should not import framework code.
- If it does, extract a boundary (see `clean-architecture-layers.md`).

## What Shameless Green Is NOT

- It is not an excuse to write untested code.
- It is not a permanent state — you refactor when smells appear or when
  a new requirement demands structural change.
- It is not "technical debt." It is an honest starting point that you
  improve incrementally based on evidence.

## When to Stop Being Shameless

Move from Shameless Green to refactoring when:
- A new requirement arrives that the current structure cannot accommodate
  without significant duplication or tangled conditionals.
- Code smells accumulate to the point where the code is hard to read.
- You now have enough concrete examples to see the right abstraction.

Never refactor "just because." Refactor in response to a specific need
or a specific smell.

## Example: The Wrong Instinct vs. Shameless Green

**Wrong instinct (speculative):**
```
First test → immediately create an abstract base class with
two subclasses because "I know there will be variants."
```

**Shameless Green:**
```
First test → return a hardcoded value.
Second test → add an if/else.
Third test → add another branch.
Fourth test → now I have four concrete examples and can SEE
the pattern. NOW I extract.
```

The difference: the second approach extracts from evidence.
The first extracts from imagination.
