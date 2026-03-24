# Extracting Classes and Abstractions

## The Decision Flowchart

Before extracting any abstraction, walk through this:

```
Do I have 3+ concrete examples of this pattern?
│
├── No → Don't extract. Tolerate duplication. Wait for more examples.
│
└── Yes
    │
    Can I name the concept in domain terms (not implementation terms)?
    │
    ├── No → Don't extract. The abstraction isn't clear yet.
    │         (If you can't name it, you don't understand it.)
    │
    └── Yes
        │
        Will this extraction simplify the next change I need to make?
        │
        ├── No → Don't extract. It's not time yet.
        │         (Extraction without a forcing function is speculation.)
        │
        └── Yes
            │
            Extract. Follow the procedure below.
```

## Naming: Domain Concepts, Not Mechanisms

The name of your new class should reflect what the concept *means* in
the domain, not how it works in code.

**Good names (domain concepts):**
- `BottleNumber` (a number with bottle-specific behavior)
- `Subscription` (a business concept)
- `ShippingPolicy` (a domain rule)
- `InvoiceLine` (a domain entity)

**Bad names (implementation mechanisms):**
- `StringFormatter` (what it does, not what it means)
- `DataProcessor` (vague, implementation-focused)
- `HelperUtils` (not a concept at all)
- `BaseHandler` (an abstraction looking for a purpose)

If you find yourself reaching for words like "Manager," "Helper,"
"Processor," "Handler," or "Utils," stop. These are signs you haven't
identified the domain concept yet.

## The Extraction Procedure

This follows Martin Fowler's Extract Class refactoring, adapted with
Metz's emphasis on incremental safety.

### Step 1: Create the new class with copied methods

Copy (don't move) the relevant methods from the source class into the
new class. The old class continues to work unchanged. Run tests —
this only verifies the new code parses.

### Step 2: Give the new class its data

Add an `initialize`/constructor that accepts the data the methods
need. Add an accessor/getter for it. Run tests.

### Step 3: Wire in the new class without using it

In ONE method of the old class, create an instance of the new class
and call the corresponding method — but discard the result. The old
code still produces the actual return value. Run tests.

This proves the new class can be instantiated and its method can
execute without errors.

### Step 4: Use the result

Move the new class instantiation to the end of the old method (or
replace the old logic with the new call). The new class now produces
the return value. Run tests.

### Step 5: Delete the old implementation

Remove the now-unused code from the old method. Run tests.

### Step 6: Repeat for remaining methods

Wire in the remaining methods one at a time, following steps 3-5
for each.

### Step 7: Remove the argument redundancy

If the new class holds the data in an instance variable but its
methods still accept it as an argument (because they were copied
verbatim), now is the time to clean up. Remove the argument from
each method and have it read from the instance variable instead.
One method at a time. Run tests after each.

## When NOT to Extract

Do not extract a class when:

- You have only 1-2 examples of the pattern. Wait for the third.
- The "shared" code exists in different architectural layers. Code
  that looks similar across layers often changes for different
  reasons. Duplication across boundaries is usually cheaper than
  coupling.
- You are extracting to satisfy a design pattern rather than a
  domain concept. Patterns are discovered, not applied.
- The extraction would make the code harder to follow for a new
  reader without adding any concrete benefit.

## Immutability Preference

When extracting a new class, prefer making it immutable:

- Set all data in the constructor.
- Don't provide setters.
- If state needs to change, return a new instance.

Immutable objects are simpler to reason about, safer to share, and
easier to test. Only introduce mutability when there's a concrete
performance or usability reason.

## The Liskov Substitution Principle

When extracting a class hierarchy (base class + subclasses), every
subclass must be substitutable for the base class. This means:

- Overridden methods must accept the same types of input.
- Overridden methods must return the same types of output.
- If the base class method returns an object you can send `quantity`
  to, the subclass method must also return an object that responds
  to `quantity`.

If a subclass needs to return a fundamentally different type, the
hierarchy is wrong. Rethink the abstraction.
