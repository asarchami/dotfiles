---
name: go-context
description: "Go context.Context — propagate the request's session: creation, propagation, cancellation, timeouts, deadlines, request-scoped values, trace context. Use when writing or reviewing any Go code that takes or passes context, touches a database, or spawns goroutines."
license: MIT
---

# Go Context

**Leading word: propagate.** `context.Context` is the request's session — the cancellation signal, deadline, and request-scoped data that every operation in the same unit of work shares. The discipline is one verb: **propagate** the same context through the whole chain, and derive from it only with a deferred cancel.

## Steps

1. **Take ctx first.** Every function that reaches a database, an external API, or a goroutine takes `ctx context.Context` as its first parameter.

   *Done when: no function on the call path reaches an external side effect without receiving ctx.*

2. **Propagate, don't recreate.** Pass the caller's context down the chain. `context.Background()` belongs only at entry points (main, init, tests); `context.TODO()` is a placeholder while wiring.

   *Done when: no `context.Background()` or `context.TODO()` appears in the middle of a request path.*

3. **Derive with a deferred cancel.** `WithCancel` for manual control, `WithTimeout` for a duration, `WithDeadline` for an absolute time — and `defer cancel()` on the same line you derive.

   *Done when: every derived context has its cancel deferred immediately; `go vet` reports nothing.*

4. **Bound the values.** Carry only request-scoped metadata (request ID, user ID) as context values under an unexported key type. Function parameters and struct fields are the wrong home for them.

   *Done when: every value key is an unexported type and the value is request metadata, not a parameter.*

5. **Start from the source.** Handlers use `r.Context()`; database calls use the `*Context` variants (`QueryContext`, `ExecContext`); client calls use `NewRequestWithContext`.

   *Done when: the request's context reaches every downstream call without a fresh Background or TODO.*

6. **Detach with intent.** Work that must outlive the request roots itself in the parent context with `context.WithoutCancel` (Go 1.21+) — never a newly created Background.

   *Done when: background work is detached via WithoutCancel, not disconnected.*

## Reference

| Situation | Create |
| --- | --- |
| Entry point (main, init, test) | `context.Background()` |
| Caller doesn't provide one yet | `context.TODO()` |
| Inside an HTTP handler | `r.Context()` |
| Manual cancellation | `context.WithCancel(parent)` |
| Deadline or timeout | `context.WithTimeout(parent, d)` / `context.WithDeadline(parent, t)` |

- **[Cancellation, Timeouts & Deadlines](./references/cancellation.md)** — propagation mechanics, `<-ctx.Done()`, `AfterFunc`, `WithoutCancel`
- **[Values & Cross-Service Tracing](./references/values-tracing.md)** — unexported keys, OpenTelemetry trace headers, correlation IDs
- **[HTTP Servers & Service Calls](./references/http-services.md)** — handler context, client timeouts, `*Context` DB variants

## Watch for

| Failure | Positive |
| --- | --- |
| `context.Background()` mid-request | Propagate the caller's context |
| `nil` context passed | `context.TODO()` when uncertain |
| Context stored in a struct | Pass explicitly through parameters |
| `cancel()` not deferred | `defer cancel()` on the derivation line |
| Exported value key (collision-prone) | Unexported key type |

## Cross-references

- → See `go-concurrency` for goroutine cancellation with context
- → See `go-database` for `QueryContext` / `ExecContext`
- → See `go-observability` for OpenTelemetry trace propagation
- → See `go-patterns` for timeout and resilience patterns
- → See `go-lint` for `govet` / `staticcheck` enforcement
