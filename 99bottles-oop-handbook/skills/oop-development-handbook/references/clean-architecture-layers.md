# Clean Architecture — Layers and the Dependency Rule

## The One Rule That Matters

**Dependencies point inward.** Nothing in an inner layer knows about
anything in an outer layer.

```
┌─────────────────────────────────────────┐
│          Frameworks & Drivers           │  ← Outermost
│  ┌─────────────────────────────────┐    │
│  │     Interface Adapters          │    │
│  │  ┌─────────────────────────┐    │    │
│  │  │     Use Cases           │    │    │
│  │  │  ┌─────────────────┐    │    │    │
│  │  │  │   Entities      │    │    │    │  ← Innermost
│  │  │  └─────────────────┘    │    │    │
│  │  └─────────────────────────┘    │    │
│  └─────────────────────────────────┘    │
└─────────────────────────────────────────┘
```

## Layer Responsibilities

### Entities (innermost)

Domain objects and business rules. Value objects. Things that would
exist even if you had no software at all.

- Depend on: **nothing**
- Contain: Domain logic, validation rules, value calculations
- Do NOT contain: Database annotations, serialization logic,
  framework-specific types, HTTP concepts

**Test:** Can you describe this class to a domain expert who doesn't
know what a database is? If yes, it belongs here.

### Use Cases

Application-specific business rules. Orchestration of entities to
accomplish a task.

- Depend on: **Entities only**
- Contain: Workflow logic, coordination between entities, application
  rules that wouldn't exist without the software
- Do NOT contain: Database queries, HTTP handling, UI logic

**Test:** If you swapped your database from PostgreSQL to SQLite,
would this class change? If yes, it's in the wrong layer.

### Interface Adapters

Translators between the use cases and the outside world. Controllers,
presenters, gateways, repository implementations.

- Depend on: **Use Cases and Entities**
- Contain: Repository implementations, API controllers, presenters,
  data mappers, format converters
- Do NOT contain: Business rules, domain logic

**Test:** Does this class translate between a domain concept and an
external format? If yes, it's an adapter.

### Frameworks & Drivers (outermost)

Database engines, web frameworks, UI frameworks, external services.
Thin glue code that wires adapters to infrastructure.

- Depend on: **everything inward**
- Contain: Configuration, framework boilerplate, driver setup

## When to Introduce Each Layer

Do NOT build all four layers on day one for every feature. Introduce
them incrementally based on concrete need.

### Always do from the start:

- **Put domain logic in entities.** This costs almost nothing.
  If you write a method that calculates, validates, or decides
  something about the domain, put it on a domain object — not in a
  controller, not in a database query, not in a UI handler.

### Introduce Use Cases when:

- The same domain operation is triggered from 2+ entry points
  (API endpoint AND a CLI command, or a web controller AND a
  background job).
- You notice orchestration logic (do A, then B, then C) repeated
  in multiple controllers or handlers.

### Introduce Adapters when:

- Framework code is leaking into domain logic (your entity imports
  a database library).
- You need to swap an implementation (move from in-memory store to
  database, or switch HTTP clients).
- Testing requires mocking infrastructure — extract the interface
  so you can inject a test double.

### Full four-layer architecture when:

- The system has multiple entry points (web, CLI, queue, scheduled).
- Multiple infrastructure concerns (database, cache, external APIs).
- The domain is complex enough that isolating it pays for itself.

**Many features don't need all four layers.** A simple CRUD endpoint
with no business logic can live in two layers (adapter + framework).
Don't add layers for architecture theater.

## The Dependency Rule in Practice

### Repository pattern

The *interface* lives in the domain or use-case layer:

```
// In the domain layer — defines WHAT is needed
abstract class OrderRepository {
  Future<Order> findById(String id);
  Future<void> save(Order order);
}
```

The *implementation* lives in the adapter layer:

```
// In the adapter layer — defines HOW it's done
class PostgresOrderRepository implements OrderRepository {
  // Uses database driver, SQL, ORM — all infrastructure concerns
}
```

The use case depends on the interface. It never knows about Postgres.

### Return types

Domain methods return domain types. Never return ORM models, HTTP
responses, or framework-specific types from a domain method.

If a framework needs data in a specific format, the adapter layer
does the conversion.

### Import test

When writing an import/require statement:
- If you're in a domain file and importing a framework → **STOP.**
  You are violating the dependency rule.
- Introduce an interface or port in the domain layer.
- Implement it in the adapter layer.
- Inject the implementation.

## Layering Adds Cost

Each layer boundary introduces:
- An interface/abstraction that must be maintained.
- An injection site that must be wired.
- Indirection that makes the code harder to follow.

This cost is justified when the boundary provides real protection
against change. It is not justified when it's added "for consistency"
or "just in case." Let the code tell you when it needs a boundary.
