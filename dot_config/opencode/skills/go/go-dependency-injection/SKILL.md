---
name: go-dependency-injection
description: "Go dependency injection — inject dependencies through constructors rather than having components create or find them. Use when designing service wiring for a new project, refactoring coupled or init()-heavy code into injectable services, or choosing between manual DI, google/wire, uber-go/dig+fx, and samber/do."
license: MIT
---

# Go Dependency Injection

**Leading word: inject.** Every service declares what it needs; the caller provides it. The discipline: **inject** dependencies through constructors, keep interfaces where they're consumed, and confine the container to the composition root.

## Steps — design wiring

1. **Map the dependency graph.** List every service and its dependencies; classify each as singleton (DB connections, caches) or transient (stateless).

   *Done when: every service's dependencies are listed and each is classified singleton or transient.*

2. **Choose the injection style.** Under ~10 services, manual constructors; larger graphs or lifecycle needs (health checks, graceful shutdown, lazy loading, scopes) justify a library. Justify the choice against the decision table below.

   *Done when: the chosen approach is justified by size, type-safety, and lifecycle needs, with a reason.*

3. **Define interfaces where consumed.** Constructors accept interfaces and return structs — mock at the interface boundary.

   *Done when: no constructor depends on a concrete type it only uses through its methods.*

4. **Wire at the composition root.** `main()` or app startup builds the graph and calls constructors; no component creates its own dependencies.

   *Done when: no dependency is created inside a component and all wiring lives in the composition root.*

5. **Manage lifecycle explicitly.** State which services are lazy, which are singletons, and what shutdown/health behavior each needs — manual or via the container.

   *Done when: every stateful service has a defined init, shutdown, and health path.*

6. **Verify testability.** Each service can be constructed in a test with mocks at its interface boundary.

   *Done when: every service builds in a test with mocked dependencies.*

## Steps — refactor coupled code

1. **Locate hidden dependencies.** Find global variables and `init()` service setup that create or find dependencies.

   *Done when: every global or init()-created dependency is inventoried for conversion.*

2. **Identify interface boundaries.** Map concrete-type dependencies that consumers use only through methods.

   *Done when: each such concrete dependency has an interface defined at its consumption point.*

3. **Find service-locator patterns.** Locate the container passed as an argument or a registry accessed globally.

   *Done when: no component receives the container; each receives only the dependencies it needs.*

4. **Migrate incrementally.** Convert services to constructor injection and move wiring into the composition root; adopt a library only when manual wiring gets fragile (15+ services, lifecycle, scopes).

   *Done when: services inject through constructors at the composition root and tests construct them with mocks.*

## Reference

### Decision table

| Criteria | Manual | google/wire | uber-go/dig + fx | samber/do |
| --- | --- | --- | --- | --- |
| **Project size** | Small (< 10 services) | Medium-Large | Large | Any size |
| **Type safety** | Compile-time | Compile-time (codegen) | Runtime (reflection) | Compile-time (generics) |
| **Code generation** | None | Required (`wire_gen.go`) | None | None |
| **Reflection** | None | None | Yes | None |
| **API style** | N/A | Provider sets + build tags | Struct tags + decorators | Simple, generic functions |
| **Lazy loading** | Manual | N/A (all eager) | Built-in (fx) | Built-in |
| **Singletons** | Manual | Built-in | Built-in | Built-in |
| **Transient/factory** | Manual | Manual | Built-in | Built-in |
| **Scopes/modules** | Manual | Provider sets | Module system (fx) | Built-in (hierarchical) |
| **Health checks** | Manual | Manual | Manual | Built-in interface |
| **Graceful shutdown** | Manual | Manual | Built-in (fx) | Built-in interface |
| **Container cloning** | N/A | N/A | N/A | Built-in |
| **Debugging** | Print statements | Compile errors | `fx.Visualize()` | `ExplainInjector()`, web interface |
| **Go version** | Any | Any | Any | 1.18+ (generics) |
| **Learning curve** | None | Medium | High | Low |

### When to adopt a library

| Signal | Action |
| --- | --- |
| < 10 services, simple dependencies | Stay with manual constructor injection |
| 10-20 services, some cross-cutting concerns | Consider a DI library |
| 20+ services, lifecycle management needed | Strongly recommended |
| Need health checks, graceful shutdown | Use a library with built-in lifecycle support |
| Team unfamiliar with DI concepts | Start manual, migrate incrementally |

### Why DI

Dependency injection swaps real implementations for mocks in tests, keeps components decoupled behind interfaces, centralizes lifecycle (singleton/factory/lazy), and replaces global state and `init()` with explicit wiring at startup. Manual wiring is fine for a small script with 2-3 functions — don't over-engineer.

### Deep dives

- [Manual DI](./references/manual-di.md) — complete manual-constructor application example
- [google/wire](./references/google-wire.md) — compile-time code generation examples
- [uber-go/dig + fx](./references/uber-dig-fx.md) — reflection-based framework examples
- [samber/do](./references/samber-do.md) — generics-based container, clone-and-override testing

## Watch for

| Mistake | Fix |
| --- | --- |
| Global variables as dependencies | Pass through constructors or the container |
| `init()` for service setup | Explicit initialization in `main()` or the container |
| Depending on concrete types | Accept interfaces at consumption boundaries |
| Passing the container everywhere (service locator) | Inject specific dependencies, not the container |
| Deep chains (A→B→C→D→E) | Flatten — depend on repositories and config directly |
| A new container per request | One container per application; scopes for request-level isolation |
| Constructor creates its own dependency | Inject it as a parameter |

## Cross-references

- → See `go-structs-interfaces` for interface design and composition
- → See `go-testing` for testing with injected mocks
- → See `go-project-layout` for DI initialization placement
- → See `samber-do` for samber/do usage details
