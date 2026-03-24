# Replacing Conditionals With Polymorphism

## When to Apply This

Apply this pattern when:
- A conditional (if/else, switch/case, when) has grown to 3+ branches.
- A new requirement would add yet another branch.
- The branches share the same overall structure but differ in details.
- You can name the concept that distinguishes each branch.

Do NOT apply this when:
- There are only 1-2 branches. A simple conditional is fine.
- The branches don't share structure — they do fundamentally different
  things.
- You're speculating about future branches that don't exist yet.

## The Sequence (Kent Beck's Insight)

"Make the change easy (warning: this may be hard), then make the easy
change."

The sequence is:

1. Start with a conditional (Shameless Green).
2. A new requirement arrives that would make the conditional grow.
3. **STOP.** Do not add the new branch yet.
4. Refactor the existing code until it is *open* to the new requirement.
5. Now add the new requirement — it should be trivial.

Steps 1-4 are "make the change easy." Step 5 is "make the easy change."
Most of the work is in step 4.

## The Full Procedure

### Step 1: Extract a class for the concept

Using the procedure in `extract-class.md`, extract a class that holds
the behavior currently embedded in the conditional. This class
represents the *default* case.

For example, if you have a conditional that handles different bottle
numbers, extract a `BottleNumber` class that handles the common case.

### Step 2: Move the conditional methods into the new class

Each branch of the conditional becomes (or will become) an overridden
method on a subclass. But first, move all the methods that contain
conditionals into the base class.

### Step 3: Create subclasses for the special cases

For each non-default branch of the conditional, create a subclass.
Each subclass overrides only the methods where its behavior differs
from the base class.

```
BottleNumber          (base — handles the common case)
├── BottleNumber0     (overrides: quantity, action, successor)
├── BottleNumber1     (overrides: container, pronoun, successor)
└── BottleNumber6     (overrides: quantity, container)
```

### Step 4: Introduce a Factory

Create a factory method that selects the right subclass based on input.
Start with a simple conditional in the factory — this is acceptable
because the factory's *only* job is selection.

```
def self.for(number)
  case number
  when 0 then BottleNumber0
  when 1 then BottleNumber1
  when 6 then BottleNumber6
  else        BottleNumber
  end.new(number)
end
```

### Step 5: Remove the conditionals from the base class

Now that subclasses override the special behavior, the base class
methods should contain only the default (common) case. Remove all the
conditional branches — they've been replaced by the type system.

### Step 6: Add the new requirement

Create a new subclass for the new requirement. Override only the
methods that differ. Register it in the factory. Done.

If step 6 takes more than a few minutes, the refactoring in steps
1-5 wasn't complete enough. Go back and check.

## Factory Styles (From Simple to Sophisticated)

The book describes a continuum of factory styles. Start simple and
only move to more complex styles when you have a concrete need.

1. **Hard-coded conditional** (shown above) — Good for 2-5 types.
   Simple, obvious, easy to understand.

2. **Hash/Map lookup** — Good when types map cleanly to keys.
   `TYPES = { 0 => BottleNumber0, 1 => BottleNumber1 }`

3. **Self-registering objects** — Good when you want to add types
   without modifying the factory. Each subclass registers itself.
   Only use this when you genuinely have an open set of types.

Start with style 1. Move to style 2 or 3 only when style 1 becomes
a maintenance burden (which often means 7+ types).

## Defending Domain Concepts

When creating subclasses, override the specific domain methods —
don't take shortcuts. For example, if a BottleNumber6 has different
`quantity` and `container`, override those two methods separately.

Do NOT override `to_s` or `toString` with a combined string like
"1 six-pack." This:
- Hides the domain concepts (quantity and container are real things).
- Couples the subclass to the string template it was extracted from.
- Makes the class unusable in any context other than the original.

Invest in code that tells the truth about the domain. Just write it
down.

## Transitioning Return Types

When overriding methods in subclasses, maintain return type consistency.
If the base class method returns something that responds to `.action`,
the subclass must also return something that responds to `.action`.

If a subclass needs to return a `successor` that is a different type
of BottleNumber (e.g., BottleNumber0's successor is BottleNumber99),
make sure the returned object has the same interface as any other
BottleNumber. This is the Liskov Substitution Principle in practice.
