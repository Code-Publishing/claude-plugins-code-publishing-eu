# Anti-Patterns — What You Must Not Do

These are specific failure modes that AI agents are prone to. Guard
against them actively. Each pattern describes the bad behavior, why
it's harmful, and what to do instead.

---

## 1. The Speculation Trap

**What it looks like:**
Creating abstractions, generics, or patterns based on imagined future
requirements.

**Examples:**
- Creating an abstract base class from a single concrete example.
- Adding type parameters/generics "for flexibility" before a second
  type exists.
- Building a plugin system before a second plugin is needed.
- Creating a Strategy/Policy pattern when there's only one strategy.
- Adding a factory when there's only one product.
- Defining an interface when there's only one implementation.

**Why it's harmful:**
Speculative abstractions encode assumptions about the future. When
the future arrives differently than expected (and it always does),
these abstractions actively resist the changes you actually need.

**Instead:**
Write the concrete version. When a second case arrives, evaluate
whether to extract. When a third case arrives, extract with
confidence — you now have enough examples to see the real pattern.

---

## 2. The DRY Mirage

**What it looks like:**
Extracting shared code across architectural boundaries because it
"looks the same."

**Examples:**
- A validation function in the domain layer and a similar validation
  in the API adapter layer get merged into one shared utility.
- A formatting function used in both the UI layer and the export
  layer gets pulled into a common module.
- Two repositories with similar query patterns get a shared base
  class.

**Why it's harmful:**
Code in different layers changes for different reasons. The domain
validation changes when business rules change. The API validation
changes when the API contract changes. Merging them couples two
independent concerns — a change to one breaks the other.

**Instead:**
Accept that duplication across boundaries is cheaper than coupling.
Only extract shared code within the same layer, and only when the
shared concept has a clear domain name.

---

## 3. The Simplification Collapse

**This is the most dangerous anti-pattern for autonomous AI agents.**

**What it looks like:**
Replacing a nuanced implementation with a "simpler" version that
drops edge cases, error handling, or structural distinctions.

**Examples:**
- Flattening a class hierarchy back into a single class with
  conditionals because "it's simpler."
- Removing error handling, caching, or retry logic to "reduce
  complexity."
- Merging distinct domain concepts into one class for "convenience."
- Replacing a polymorphic design with a switch statement.
- Dropping validation logic that seems "unnecessary."
- Simplifying a factory to always return the same type.

**Why it's harmful:**
Complex code is usually complex for a reason. When you simplify
without understanding the reason, you're deleting knowledge — often
knowledge about edge cases that took significant effort to discover
and handle correctly.

**Instead:**
When you encounter complex code:
1. Assume it is complex for a reason.
2. Read the tests — they document the cases the code handles.
3. Read the git history — it documents why the complexity was added.
4. If you cannot determine the reason, ASK. Do not simplify
   speculatively.
5. If you have a concrete reason to simplify (e.g., the requirement
   no longer exists), verify by checking the tests first.

---

## 4. The Pattern Stampede

**What it looks like:**
Introducing multiple design patterns in a single change.

**Examples:**
- In one PR: adding a Factory, an Abstract Factory, a Builder, and
  a Registry.
- Refactoring a simple class into a Strategy pattern + Observer
  pattern + Decorator pattern simultaneously.
- Introducing dependency injection, an IoC container, and a service
  locator all at once.

**Why it's harmful:**
Each pattern adds indirection. Multiple patterns added simultaneously
make it impossible to evaluate each one independently. If something
goes wrong, you can't tell which pattern caused the problem. And the
cognitive load on the next reader is overwhelming.

**Instead:**
One pattern per refactoring. One stable landing point. Evaluate.
If more structure is needed, add the next pattern in a separate step.

---

## 5. The Rename-And-Restructure Combo

**What it looks like:**
Renaming things and changing structure simultaneously.

**Examples:**
- Moving a method to a new class while also renaming it.
- Changing a parameter name while also changing its type.
- Reordering method parameters while also adding a new one.

**Why it's harmful:**
When a test fails after a combined change, you can't tell whether
the failure is from the rename or the restructure. This violates the
fundamental rule: change one thing at a time.

**Instead:**
Rename first. Run tests. Commit. Then restructure. Run tests. Commit.
Two small, verifiable steps instead of one large, ambiguous one.

---

## 6. The Completionist Urge

**What it looks like:**
Refactoring more than is needed for the current task.

**Examples:**
- You're adding a feature to module A, but you notice module B could
  be "improved," so you refactor both.
- You extract a class and then keep extracting "while you're in there."
- You notice a code smell in code you're not changing and fix it
  alongside your feature work.

**Why it's harmful:**
Each refactoring carries risk. Combining unrelated refactorings makes
it harder to isolate failures. It also makes code review harder and
git history messier.

**Instead:**
Fix what you came to fix. Note other improvements. Do them in a
separate step (or a separate session) with their own tests and commits.

---

## 7. The God Method Avoidance Overcorrection

**What it looks like:**
Splitting a method into many tiny methods prematurely, before the
structure of the code is clear.

**Examples:**
- A 20-line method gets split into 8 three-line methods, each called
  only once, making the flow harder to follow.
- Extracting a method for every single conditional branch.
- Creating helper methods that obscure the sequence of operations.

**Why it's harmful:**
Excessive extraction creates indirection without adding clarity.
The reader must jump between many small methods to understand a single
flow. This is a common overcorrection from Clean Code's "extract till
you drop" advice.

**Instead:**
Extract methods when:
- The extracted piece has a clear domain name.
- It's called from 2+ places.
- It's obscuring the main flow of the containing method.

Don't extract just to make methods shorter.

---

## Summary Checklist

Before making any structural change, verify:

- [ ] Am I extracting from 3+ concrete examples, not from speculation?
- [ ] Can I name the new concept in domain terms?
- [ ] Am I changing only one thing (rename OR restructure, not both)?
- [ ] Am I staying within the scope of my current task?
- [ ] Are the tests still green after each individual change?
- [ ] Am I keeping the code deployable at every step?
- [ ] Am I simplifying code I actually understand?
- [ ] Am I introducing at most one new pattern?
