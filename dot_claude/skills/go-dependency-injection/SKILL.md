---
name: go-dependency-injection
description: "Comprehensive guide to dependency injection (DI) in Golang. Covers why DI matters (testability, loose coupling, lifecycle management), manual constructor injection, and the four main approaches: manual wiring, google/wire (compile-time codegen), uber-go/dig + uber-go/fx (reflection-based container and application framework), and samber/do (generics-based, no reflection). Use this skill when designing service architecture, setting up dependency injection, refactoring tightly coupled code, managing singletons or service factories, or when the user asks about inversion of control, service containers, wiring dependencies in Go, or working with `github.com/google/wire`, `go.uber.org/dig`, `go.uber.org/fx`, or `github.com/samber/do/v2`."
user-invocable: true
license: MIT
compatibility: Designed for Claude Code or similar AI coding agents, and for projects using Golang.
metadata:
  author: samber
  version: "1.1.2"
  openclaw:
    emoji: "🔌"
    homepage: https://github.com/samber/cc-skills-golang
    requires:
      bins:
        - go
    install: []
---

**Persona:** You are a Go software architect. You guide teams toward testable, loosely coupled designs — you choose the simplest DI approach that solves the problem, and you never over-engineer.

**Modes:**

- **Design mode** (new project, new service, or adding a service to an existing DI setup): assess the existing dependency graph and lifecycle needs; recommend manual injection or a library from the decision table; then generate the wiring code using the relevant library section below.
- **Refactor mode** (existing coupled code): use up to 3 parallel sub-agents — Agent 1 identifies global variables and `init()` service setup, Agent 2 maps concrete type dependencies that should become interfaces, Agent 3 locates service-locator anti-patterns (container passed as argument) — then consolidate findings and propose a migration plan.
- **Library mode** (codebase already imports `google/wire`, `uber-go/dig`, `uber-go/fx`, or `samber/do`): jump directly to that library's section below; it's self-contained with its own best practices, common mistakes, and reference links.

> **Community default.** A company skill that explicitly supersedes `go-dependency-injection` skill takes precedence.

# Dependency Injection in Go

Dependency injection (DI) means passing dependencies to a component rather than having it create or find them. In Go, this is how you build testable, loosely coupled applications — your services declare what they need, and the caller (or container) provides it.

This skill is not exhaustive. When using a DI library, refer to the library's official documentation and code examples for current API signatures.

For interface-based design foundations (accept interfaces, return structs), see the `go-code-style` skill.

## Best Practices Summary

1. Dependencies MUST be injected via constructors — NEVER use global variables or `init()` for service setup
2. Small projects (< 10 services) SHOULD use manual constructor injection — no library needed
3. Interfaces MUST be defined where consumed, not where implemented — accept interfaces, return structs
4. NEVER use global registries or package-level service locators
5. The DI container MUST only exist at the composition root (`main()` or app startup) — NEVER pass the container as a dependency
6. **Prefer lazy initialization** — only create services when first requested
7. **Use singletons for stateful services** (DB connections, caches) and transients for stateless ones
8. **Mock at the interface boundary** — DI makes this trivial
9. **Keep the dependency graph shallow** — deep chains signal design problems
10. **Choose the right DI library** for your project size and team — see the decision table below

## Why Dependency Injection?

| Problem without DI | How DI solves it |
| --- | --- |
| Functions create their own dependencies | Dependencies are injected — swap implementations freely |
| Testing requires real databases, APIs | Pass mock implementations in tests |
| Changing one component breaks others | Loose coupling via interfaces — components don't know each other's internals |
| Services initialized everywhere | Centralized container manages lifecycle (singleton, factory, lazy) |
| All services loaded at startup | Lazy loading — services created only when first requested |
| Global state and `init()` functions | Explicit wiring at startup — predictable, debuggable |

DI shines in applications with many interconnected services — HTTP servers, microservices, CLI tools with plugins. For a small script with 2-3 functions, manual wiring is fine. Don't over-engineer.

## Manual Constructor Injection (No Library)

For small projects, pass dependencies through constructors. See [Manual DI examples](./references/manual-di.md) for a complete application example.

```go
// ✓ Good — explicit dependencies, testable
type UserService struct {
    db     UserStore
    mailer Mailer
    logger *slog.Logger
}

func NewUserService(db UserStore, mailer Mailer, logger *slog.Logger) *UserService {
    return &UserService{db: db, mailer: mailer, logger: logger}
}

// main.go — manual wiring
func main() {
    logger := slog.Default()
    db := postgres.NewUserStore(connStr)
    mailer := smtp.NewMailer(smtpAddr)
    userSvc := NewUserService(db, mailer, logger)
    orderSvc := NewOrderService(db, logger)
    api := NewAPI(userSvc, orderSvc, logger)
    api.ListenAndServe(":8080")
}
```

```go
// ✗ Bad — hardcoded dependencies, untestable
type UserService struct {
    db *sql.DB
}

func NewUserService() *UserService {
    db, _ := sql.Open("postgres", os.Getenv("DATABASE_URL")) // hidden dependency
    return &UserService{db: db}
}
```

Manual DI breaks down when:

- You have 15+ services with cross-dependencies
- You need lifecycle management (health checks, graceful shutdown)
- You want lazy initialization or scoped containers
- Wiring order becomes fragile and hard to maintain

## DI Library Comparison

Go has three main approaches to DI libraries, covered in full below: [google/wire](#googlewire--compile-time-code-generation), [uber-go/dig + fx](#uber-godig--reflection-based-container), and [samber/do](#samberdo--generics-based-no-reflection).

### Decision Table

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

### Quick Comparison: Same App, Four Ways

The dependency graph: `Config -> Database -> UserStore -> UserService -> API`

**Manual**:

```go
cfg := NewConfig()
db := NewDatabase(cfg)
store := NewUserStore(db)
svc := NewUserService(store)
api := NewAPI(svc)
api.Run()
// No automatic shutdown, health checks, or lazy loading
```

**google/wire**:

```go
// wire.go — then run: wire ./...
func InitializeAPI() (*API, error) {
    wire.Build(NewConfig, NewDatabase, NewUserStore, NewUserService, NewAPI)
    return nil, nil
}
// No shutdown or health check support
```

**uber-go/fx**:

```go
app := fx.New(
    fx.Provide(NewConfig, NewDatabase, NewUserStore, NewUserService),
    fx.Invoke(func(api *API) { api.Run() }),
)
app.Run() // manages lifecycle, but reflection-based
```

**samber/do**:

```go
i := do.New()
do.Provide(i, NewConfig)
do.Provide(i, NewDatabase)    // auto shutdown + health check
do.Provide(i, NewUserStore)
do.Provide(i, NewUserService)
api := do.MustInvoke[*API](i)
api.Run()
// defer i.Shutdown() — handles all cleanup automatically
```

## When to Adopt a DI Library

| Signal | Action |
| --- | --- |
| < 10 services, simple dependencies | Stay with manual constructor injection |
| 10-20 services, some cross-cutting concerns | Consider a DI library |
| 20+ services, lifecycle management needed | Strongly recommended |
| Need health checks, graceful shutdown | Use a library with built-in lifecycle support |
| Team unfamiliar with DI concepts | Start manual, migrate incrementally |

---

## samber/do — Generics-Based, No Reflection

Type-safe dependency injection toolkit for Go based on Go 1.18+ generics — no reflection, no code generation.

**Official Resources:** [pkg.go.dev/github.com/samber/do/v2](https://pkg.go.dev/github.com/samber/do/v2) · [do.samber.dev](https://do.samber.dev) · [github.com/samber/do/v2](https://github.com/samber/do)

DO NOT USE v1 OF THIS LIBRARY. INSTALL v2 INSTEAD: `go get -u github.com/samber/do/v2`

### Core Concepts

- **The Injector (Container)**: `injector := do.New()`
- **Service Types**: Lazy (default, created on first request), Eager (created immediately), Transient (new instance per request), Value (pre-created, no instantiation)
- **Provider Functions**: `type Provider[T any] func(i Injector) (T, error)`

### Basic Usage

```go
// Register a service (lazy by default)
do.Provide(injector, func(i do.Injector) (Database, error) {
    return &PostgreSQLDatabase{connString: "postgres://..."}, nil
})

// Register a pre-created value
do.ProvideValue(injector, &Config{Port: 8080})

// Register a transient service (new instance each time)
do.ProvideTransient(injector, func(i do.Injector) (*Logger, error) {
    return &Logger{}, nil
})

// Invoke with error handling
db, err := do.Invoke[Database](injector)
// MustInvoke panics on error (use when confident service exists)
db := do.MustInvoke[Database](injector)
```

Implicit aliasing lets you register a concrete type and invoke it as an interface without an explicit adapter:

```go
do.Provide(injector, func(i do.Injector) (*PostgreSQLDatabase, error) {
    return &PostgreSQLDatabase{}, nil
})
db := do.MustInvokeAs[Database](injector) // invoke directly as interface
```

Named services disambiguate multiple providers of the same type: `do.ProvideNamed(injector, "primary-db", ...)`, `do.MustInvokeNamed[*Database](injector, "primary-db")`.

### Package Organization

```go
// infrastructure/package.go
var Package = do.Package(
    do.Lazy(func(i do.Injector) (*postgres.DB, error) {
        cfg := do.MustInvoke[*Config](i)
        return postgres.Connect(cfg.DatabaseURL)
    }),
)

// main.go
func main() {
    injector := do.New(infrastructure.Package, service.Package)
    server := do.MustInvoke[*http.Server](injector)
    go server.ListenAndServe()
    _ = injector.ShutdownOnSignalsWithContext(context.Background(), os.Interrupt)
}
```

### Best Practices

1. Depend on interfaces, not concrete types — lets you swap implementations in tests without touching production code
2. Each service should have one job — services with multiple responsibilities are harder to test and harder to replace
3. Keep dependency trees shallow — chains beyond 3-4 levels make initialization order fragile and errors harder to trace
4. Handle errors in provider functions — a silently failing provider creates a broken service that crashes later in unexpected places
5. Use scopes to organize services by lifecycle — request-scoped services prevent leaks, global services prevent redundant initialization

### Quick Reference

| Registration | Purpose | Invocation | Purpose |
| --- | --- | --- | --- |
| `do.Provide[T]()` | Register lazy service (default) | `do.Invoke[T]()` | Get service (with error) |
| `do.ProvideNamed[T]()` | Register named lazy service | `do.InvokeNamed[T]()` | Get named service |
| `do.ProvideValue[T]()` | Register pre-created value | `do.InvokeAs[T]()` | Get first service matching interface |
| `do.ProvideTransient[T]()` | Register new instance each time | `do.InvokeStruct[T]()` | Inject into struct fields using tags |
| `do.Package()` | Group service registrations | `do.MustInvoke[T]()` / `MustInvokeNamed` / `MustInvokeAs` / `MustInvokeStruct` | Panic-on-error variants |

### Testing with samber/do — Clone and Override

Container cloning creates an isolated copy where you override only the services you need to mock:

```go
func TestUserService_WithDo(t *testing.T) {
    testInjector := do.New()
    do.Override[UserStore](testInjector, &MockUserStore{
        users: map[string]*User{"1": {ID: "1", Name: "Alice"}},
    })
    do.Provide[*slog.Logger](testInjector, func(i *do.Injector) (*slog.Logger, error) {
        return slog.Default(), nil
    })
    svc := do.MustInvoke[*UserService](testInjector)
    user, err := svc.GetUser(context.Background(), "1")
    // ... assertions
}
```

For scopes, lifecycle management, struct injection, and debugging, see [samber-do-advanced.md](references/samber-do-advanced.md). For full testing patterns, see [samber-do-testing.md](references/samber-do-testing.md).

---

## google/wire — Compile-Time Code Generation

Code-generation DI toolkit. Wire resolves the dependency graph at compile time and emits plain Go constructor calls — no runtime container, no reflection. Errors appear when you run `wire ./...`, not at first request.

Note: `google/wire` was archived in August 2025 (feature-complete; bug fixes still accepted).

**Official Resources:** [pkg.go.dev](https://pkg.go.dev/github.com/google/wire) · [github.com/google/wire](https://github.com/google/wire) · [User Guide](https://github.com/google/wire/blob/main/docs/guide.md) · [Best Practices](https://github.com/google/wire/blob/main/docs/best-practices.md)

```bash
go install github.com/google/wire/cmd/wire@latest
go get github.com/google/wire
```

### Providers and Provider Sets

A provider is any Go function — inputs are dependencies, outputs are provided types. `wire.NewSet` groups providers for reuse; sets can reference other sets.

```go
func NewConfig() *Config                          { return &Config{Addr: ":8080"} }
func NewDB(cfg *Config) (*sql.DB, error)          { return sql.Open("postgres", cfg.DSN) }
func NewRedis(cfg *Config) (*redis.Client, func(), error) { // cleanup chained in reverse order
    c := redis.NewClient(&redis.Options{Addr: cfg.RedisAddr})
    return c, func() { c.Close() }, nil
}

// infra/wire.go
var InfraSet = wire.NewSet(NewConfig, NewDB, NewRedis)

// service/wire.go
var ServiceSet = wire.NewSet(
    NewUserRepo,
    NewUserService,
    wire.Bind(new(UserStore), new(*UserRepo)), // interface binding
)
```

Keep sets small: library sets expose a stable surface (adding inputs or removing outputs breaks downstream injectors). One set per package is a useful default.

### Injectors and `//go:build wireinject`

The injector file declares the initialization function. Wire generates its body into `wire_gen.go` and replaces the stub.

```go
//go:build wireinject

package main

import "github.com/google/wire"

// Wire generates the body of this function.
func InitApp() (*App, func(), error) {
    wire.Build(InfraSet, ServiceSet, NewApp)
    return nil, nil, nil // replaced by codegen
}
```

The `//go:build wireinject` tag prevents the stub from being compiled into the binary — only `wire_gen.go` (which has no such tag) makes it through `go build`. Without this tag, both files define the same function, causing a compile error.

### Interface Bindings

Wire forbids implicit interface satisfaction — declare bindings explicitly so the graph is unambiguous when multiple types implement the same interface:

```go
var Set = wire.NewSet(
    NewPostgresUserRepo,
    wire.Bind(new(UserStore), new(*PostgresUserRepo)),
)
```

### Struct Providers and Values

```go
wire.Struct(new(Server), "Logger", "DB") // inject named fields
wire.Struct(new(Server), "*")            // inject all non-excluded fields
wire.Value(Foo{X: 42})                   // constant expression (no fn calls / channels)
wire.InterfaceValue(new(io.Reader), os.Stdin) // interface-typed literal
wire.FieldsOf(new(Config), "DSN", "Addr")    // promote struct fields as graph nodes
```

Two providers for the same underlying type collide — wrap in distinct named types (`type PrimaryDSN string`, `type ReplicaDSN string`) so each has exactly one provider.

### Codegen Workflow

```bash
wire ./...           # regenerate all injectors in the module
wire check ./...     # validate graph without regenerating (fast CI check)
```

Run `wire ./...` after every constructor signature change. Add `//go:generate go run github.com/google/wire/cmd/wire` to injector files so `go generate ./...` also works. Commit `wire_gen.go` — it must stay in sync for CI builds.

### Best Practices

1. Never edit `wire_gen.go` — it is overwritten on every `wire ./...` run. Treat it as a build artifact that happens to be committed.
2. Always add `//go:build wireinject` to injector files — omitting it causes duplicate-symbol compile errors.
3. Use named types to distinguish values of the same underlying type — wire enforces one provider per type.
4. Keep library provider sets minimal and backward-compatible — adding new required inputs breaks downstream injectors.
5. Return `(T, func(), error)` from cleanup providers and let wire chain them in reverse order, handling partial construction failures.
6. Keep injector files focused — one function per file; delegate to per-package sets instead of fat injectors.

### Common Mistakes

| Mistake | Fix |
| --- | --- |
| Editing `wire_gen.go` manually | Never edit it. Change providers or injectors and re-run `wire ./...`. |
| Missing `//go:build wireinject` | Add the tag as the very first line of every injector file. |
| Two providers returning `*sql.DB` | Wrap with named types (`type PrimaryDB *sql.DB` or a wrapper struct). |
| Injecting an interface without `wire.Bind` | Add `wire.Bind(new(MyInterface), new(*MyImpl))` to the provider set. |
| Forgetting to re-run `wire ./...` after changes | Run wire before `go build`; add it to `go generate` or a Makefile target. |
| Calling `cleanup()` without guarding for nil | Wire returns nil cleanup on construction error; guard with `if cleanup != nil { defer cleanup() }`. |

Wire generates plain Go constructors, so unit tests use manual injection — no container to clone or reset. For test injectors, fake bindings, and CI stale-check patterns, see [wire-testing.md](references/wire-testing.md). For cleanup chains, multiple injectors, set nesting, and the error catalogue, see [wire-advanced.md](references/wire-advanced.md). For a full HTTP server / multi-injector build / CLI embedding, see [wire-recipes.md](references/wire-recipes.md).

If you encounter a bug or unexpected behavior in google/wire, open an issue at <https://github.com/google/wire/issues>.

---

## uber-go/dig — Reflection-Based Container

Reflection-based DI toolkit, designed to power application frameworks (it is the engine behind `uber-go/fx`) and resolve object graphs during startup.

**Official Resources:** [pkg.go.dev/go.uber.org/dig](https://pkg.go.dev/go.uber.org/dig) · [github.com/uber-go/dig](https://github.com/uber-go/dig)

```bash
go get go.uber.org/dig
```

**Choose dig** when you need the wiring graph only: CLI tools, libraries exposing a container to callers, test harnesses, or embedding DI into an existing app that manages its own lifecycle. **Choose fx** (below) for long-running services where lifecycle and signal handling are non-negotiable.

### Container, Provide, Invoke

```go
c := dig.New()

// Register a constructor — lazy, only runs when its output is needed
err := c.Provide(func(cfg *Config) (*sql.DB, error) {
    return sql.Open("postgres", cfg.DSN)
})

// Pull a service out of the container by asking for it as a function parameter
err = c.Invoke(func(db *sql.DB) error {
    return db.Ping()
})
```

Constructors are **lazy** and **memoized**: each output type is built once and shared (singleton per container). `Provide` errors at registration if the constructor is malformed; `Invoke` returns the constructor's error wrapped with the dependency path that triggered it.

Useful options: `dig.DeferAcyclicVerification()` (faster startup), `dig.RecoverFromPanics()` (turn panics into `dig.PanicError`), `dig.DryRun(true)` (validate without invoking).

### Parameter and Result Objects

Once a constructor has 4+ dependencies, embed `dig.In` to group them as struct fields:

```go
type HandlerParams struct {
    dig.In

    Logger *zap.Logger
    DB     *sql.DB
    Cache  *redis.Client `optional:"true"`           // zero value if not provided
    DBRO   *sql.DB       `name:"readonly"`           // named dependency
    Routes []http.Handler `group:"routes"`           // value group
}
```

Return several values from one constructor and attach `name`/`group` tags with `dig.Out`. **Flatten** — append `,flatten` (e.g. `group:"routes,flatten"`) to unwrap a slice instead of nesting it. Group order is **not guaranteed**; if order matters, provide an explicit ordered slice from a single constructor.

Register a concrete constructor and expose it under one or more interfaces without a separate adapter: `c.Provide(NewPostgresDB, dig.As(new(Database), new(io.Closer)))`.

dig has **no built-in lifecycle**. If you need OnStart/OnStop hooks, signal handling, and graceful shutdown, use fx (below).

### Best Practices

1. Keep the container at the composition root — never pass `*dig.Container` as a parameter.
2. Depend on interfaces, not concrete types.
3. Prefer parameter objects (`dig.In` structs) once a constructor has 4+ dependencies.
4. Group registration by module (one file per module that calls `c.Provide` for its types).
5. Validate the graph eagerly in tests — call `c.Invoke` against the composition root in CI. `DryRun(true)` skips constructor execution.
6. Return errors from constructors instead of panicking — dig wraps them with the dependency path.

### Common Mistakes

| Mistake | Fix |
| --- | --- |
| Passing the container into services | The container belongs to `main()`. Inject the typed dependencies a service needs. |
| Two providers for the same type without `Name` | dig errors at `Provide` time. Name them, or merge into a single `dig.Out` result struct. |
| Ignoring `Provide` errors | Wrap each `Provide` with a `must` helper. |
| Using groups when ordering matters | Groups are unordered. Provide an explicit ordered slice with one constructor instead. |
| Constructors with side effects on import | Keep `init()` empty — start work only inside the constructor. |

dig containers are cheap — build a fresh one per test, override providers with `Decorate`, and call `Invoke` to drive the system. For per-test wiring, shared helpers, and graph validation in CI, see [dig-testing.md](references/dig-testing.md). For Decorate, Scopes, optional deps, error helpers, and Visualize, see [dig-advanced.md](references/dig-advanced.md). For end-to-end recipes, see [dig-recipes.md](references/dig-recipes.md).

If you encounter a bug or unexpected behavior in uber-go/dig, open an issue at <https://github.com/uber-go/dig/issues>.

---

## uber-go/fx — Application Framework

Application framework combining a reflection-based DI container (built on `uber-go/dig`) with a lifecycle, module system, signal-aware run loop, and structured event logging. For long-running services where boot order, graceful shutdown, and modular composition matter.

**Official Resources:** [pkg.go.dev/go.uber.org/fx](https://pkg.go.dev/go.uber.org/fx) · [uber-go.github.io/fx](https://uber-go.github.io/fx/) · [github.com/uber-go/fx](https://github.com/uber-go/fx)

```bash
go get go.uber.org/fx
```

fx re-exports dig's `dig.In`/`dig.Out` as `fx.In`/`fx.Out` — the DI primitives are identical to dig. What fx adds: lifecycle hooks (`fx.Lifecycle` OnStart/OnStop), a module system (`fx.Module`), a signal-aware run loop (`app.Run()` blocks on SIGINT/SIGTERM), structured event logging, and startup/shutdown timeouts.

### The Application

```go
app := fx.New(
    fx.Provide(NewLogger, NewDatabase, NewServer),
    fx.Invoke(RegisterRoutes),
)
app.Run() // blocks until SIGINT/SIGTERM, then runs OnStop hooks
```

Boot stages: `fx.New` validates types (constructors do not run); `app.Start(ctx)` runs each `fx.Invoke` and fires OnStart hooks in topological order; main blocks on `app.Done()`; `app.Stop(ctx)` fires OnStop hooks in reverse order. Default timeout is **15 seconds** — override with `fx.StartTimeout`/`fx.StopTimeout`.

`fx.Provide` registers constructors; `fx.Invoke` is the trigger — without an Invoke (directly or transitively) referencing a type, its constructor never runs.

### Lifecycle Hooks

Inject `fx.Lifecycle` and append hooks. Constructors should return quickly; long-running work belongs in `OnStart`.

```go
func NewHTTPServer(lc fx.Lifecycle, log *zap.Logger, cfg *Config) *http.Server {
    srv := &http.Server{Addr: cfg.Addr}
    lc.Append(fx.Hook{
        OnStart: func(ctx context.Context) error {
            ln, err := net.Listen("tcp", srv.Addr)
            if err != nil { return err }
            go srv.Serve(ln) // blocking work in a goroutine
            return nil
        },
        OnStop: func(ctx context.Context) error {
            return srv.Shutdown(ctx)
        },
    })
    return srv
}
```

Both callbacks receive a context bounded by `StartTimeout`/`StopTimeout` — respect cancellation. **OnStart must return quickly**; otherwise startup hangs and dependent hooks never fire. `fx.StartHook`/`fx.StopHook`/`fx.StartStopHook` adapt simpler signatures.

### fx.Annotate and Value Groups

`fx.Annotate` wraps a constructor to add tags or interface bindings without an `fx.Out` struct:

```go
fx.Provide(
    fx.Annotate(NewPrimaryDB, fx.ResultTags(`name:"primary"`)),
    fx.Annotate(NewPostgresDB, fx.As(new(Database))),
    fx.Annotate(NewUserHandler, fx.As(new(http.Handler)), fx.ResultTags(`group:"routes"`)),
)
```

Value groups (many constructors, one consumer slice) work the same as dig's — append `,flatten` to unwrap, and remember group order is not guaranteed.

### fx.Module

`fx.Module` groups providers, invokes, and decorators under a name. Modules **scope decorators** to themselves and their children:

```go
var DatabaseModule = fx.Module("database",
    fx.Provide(NewConnection, NewUserRepository),
    fx.Decorate(func(log *zap.Logger) *zap.Logger { return log.Named("db") }),
)

func main() {
    fx.New(fx.Provide(NewConfig, NewLogger), DatabaseModule, HTTPModule).Run()
}
```

Treat each module as a small library that can be lifted into another app — its public surface is the types it Provides.

### Best Practices

1. Keep `main()` thin — providers, modules, and a single `Run()`. Push real work into modules.
2. Use lifecycle hooks instead of `init()` or goroutines launched from constructors.
3. OnStart must return promptly — long work goes in a goroutine inside the hook.
4. Respect `ctx.Done()` in hooks — ignoring cancellation leaks the underlying goroutine even after the hook is reported as timed out.
5. Group by module, not by layer — a module owns the providers, lifecycle, and decorators for one concern.
6. Use `fx.Annotate` for tags rather than wrapping a constructor in an `fx.Out` struct.
7. Replace `fx.Provide` with `fx.Supply` for pre-built values (config, command-line flags).
8. Validate the graph in CI by booting under `fx.New(...).Err()`.

### Common Mistakes

| Mistake | Fix |
| --- | --- |
| Long-running work directly in OnStart | Spawn a goroutine inside OnStart; the hook itself must return quickly. |
| `fx.Provide` something that should be `fx.Supply` | Pre-built values (config, secrets) belong in `fx.Supply`. |
| Module decorator leaking to siblings | Decorate inside `fx.Module(...)` — a top-level `fx.Decorate` is global. |
| Group order assumed | Groups are unordered. Provide an ordered slice from one constructor if order matters. |
| Constructors with side effects | Side effects belong in OnStart — constructors should be cheap and pure-ish. |
| Forgotten `fx.Invoke` | Without an Invoke (or downstream consumer), constructors never run. |

Use `go.uber.org/fx/fxtest` to integrate fx with `*testing.T` (failures call `t.Fatal`, `RequireStop` registers as `t.Cleanup`). `fx.Populate(&target)` pulls values out of the graph; `fx.Replace` swaps real dependencies for fakes. For full patterns, see [fx-testing.md](references/fx-testing.md). For Supply/Replace/Decorate, optional deps, and custom event logging, see [fx-advanced.md](references/fx-advanced.md). For end-to-end recipes, see [fx-recipes.md](references/fx-recipes.md).

If you encounter a bug or unexpected behavior in uber-go/fx, open an issue at <https://github.com/uber-go/fx/issues>.

---

## Testing with DI

DI makes testing straightforward — inject mocks instead of real implementations:

```go
type MockUserStore struct {
    users map[string]*User
}

func (m *MockUserStore) FindByID(ctx context.Context, id string) (*User, error) {
    u, ok := m.users[id]
    if !ok {
        return nil, ErrNotFound
    }
    return u, nil
}

func TestUserService_GetUser(t *testing.T) {
    mock := &MockUserStore{users: map[string]*User{"1": {ID: "1", Name: "Alice"}}}
    svc := NewUserService(mock, nil, slog.Default())

    user, err := svc.GetUser(context.Background(), "1")
    if err != nil {
        t.Fatalf("unexpected error: %v", err)
    }
    if user.Name != "Alice" {
        t.Errorf("got %q, want %q", user.Name, "Alice")
    }
}
```

Each library's own section above links to its own testing reference (container cloning for samber/do, fake bindings for wire, per-test wiring for dig, `fxtest` for fx).

## Common Mistakes (General)

| Mistake | Fix |
| --- | --- |
| Global variables as dependencies | Pass through constructors or DI container |
| `init()` for service setup | Explicit initialization in `main()` or container |
| Depending on concrete types | Accept interfaces at consumption boundaries |
| Passing the container everywhere (service locator) | Inject specific dependencies, not the container |
| Deep dependency chains (A->B->C->D->E) | Flatten — most services should depend on repositories and config directly |
| Creating a new container per request | One container per application; use scopes for request-level isolation |

## Cross-References

- → See `go-code-style` skill for interface design, composition, and "accept interfaces, return structs"
- → See `go-testing` skill for general testing patterns
- → See `go-project-layout` skill for DI initialization placement
- → See `go-concurrency` skill for context propagation in fx's OnStart/OnStop hooks

## References

- [samber/do/v2 documentation](https://do.samber.dev) | [github.com/samber/do/v2](https://github.com/samber/do)
- [google/wire user guide](https://github.com/google/wire/blob/main/docs/guide.md)
- [uber-go/fx documentation](https://uber-go.github.io/fx/)
- [uber-go/dig](https://github.com/uber-go/dig)
