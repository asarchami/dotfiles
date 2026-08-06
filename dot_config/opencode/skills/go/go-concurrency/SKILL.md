---
name: go-concurrency
description: "Go concurrency — ownership discipline for goroutines, channels, select, locks, sync primitives, errgroup, singleflight, worker pools, fan-out/fan-in. Use when writing or reviewing concurrent Go code, or when you spot goroutine leaks, race conditions, or channel ownership issues."
license: MIT
---

# Go Concurrency

**Leading word: ownership.** Every goroutine is a liability until proven necessary. The discipline: every goroutine has an owner with three answers — **how it exits, how to stop it, how to wait for it**. Channels transfer ownership explicitly; mutexes make it implicit. Structured concurrency means each goroutine has a clear owner and a predictable exit.

## Steps — write concurrent code

1. **Choose the primitive.** Match the job to a channel, mutex, atomic, or sync primitive using the tables below — not the most familiar one.

   *Done when: the chosen primitive matches the scenario table, with a reason.*

2. **Plan the exit before `go`.** Answer three questions: how it exits (context cancel, channel close, or explicit signal), how to stop it (pass `ctx` or a done channel), how to wait for it (`sync.WaitGroup` or `errgroup`).

   *Done when: every goroutine you are about to spawn has all three answers written down.*

3. **Assert channel ownership.** The creator/sender owns and closes the channel; specify direction (`chan<-`, `<-chan`) at boundaries; send copies, not pointers.

   *Done when: only the sender closes; every channel parameter is directional; no pointer is sent where a copy works.*

4. **Select with the context.** Every `select` includes `case <-ctx.Done()`; reuse `time.NewTimer` + `Reset` instead of `time.After` in loops.

   *Done when: no select lacks `ctx.Done()`; no `time.After` appears in a loop.*

5. **Add before you go.** `wg.Add(1)` before `go func()` — never inside it — so `Wait` can't return before `Add` runs.

   *Done when: every `Add` precedes its `go`, in source order.*

6. **Prove it with `-race` and goleak.** Run `go test -race ./...`; goroutine-heavy packages install `goleak.VerifyTestMain`.

   *Done when: race detector is clean and no test suite leaks goroutines.*

## Steps — review or audit

1. **Scan the diff for spawns.** Every `go func()` must have an exit, a stop signal, and a wait mechanism. *Done when: each spawn on the changed lines is answered.*
2. **Check shared state.** Mutable globals and struct fields are synchronized; no map is read and written concurrently (hard crash). *Done when: every shared write is guarded.*
3. **Audit channels.** Ownership, direction, closure, and buffer size each have a justification. *Done when: each channel answers who closes it and why it's buffered.*
4. **Check the hot list.** No `time.After` in loops, no missing `ctx.Done()`, no unbounded spawning (`errgroup.SetLimit(n)` instead), no mutex held across I/O. *Done when: the hot list is clean.*

## Reference

### Channel vs Mutex vs Atomic

| Scenario | Use | Why |
| --- | --- | --- |
| Passing data between goroutines | Channel | Communicates ownership transfer |
| Coordinating goroutine lifecycle | Channel + context | Clean shutdown with select |
| Protecting shared struct fields | `sync.Mutex` / `sync.RWMutex` | Simple critical sections |
| Simple counters, flags | `sync/atomic` | Lock-free, lower overhead |
| Many readers, few writers on a map | `sync.Map` | Read-heavy optimized |
| Caching expensive computations | `sync.Once` / `singleflight` | Execute once or deduplicate |

### WaitGroup vs errgroup

| Need | Use |
| --- | --- |
| Wait for goroutines, errors not needed | `sync.WaitGroup` |
| Wait + collect first error | `errgroup.Group` |
| Wait + cancel siblings on first error | `errgroup.WithContext` |
| Wait + limit concurrency | `errgroup.SetLimit(n)` |

### Sync primitives

| Primitive | Use case | Key notes |
| --- | --- | --- |
| `sync.Mutex` | Protect shared state | Keep critical sections short; never hold across I/O |
| `sync.RWMutex` | Many readers, few writers | Never upgrade RLock to Lock (deadlock) |
| `sync/atomic` | Simple counters, flags | Prefer typed atomics (Go 1.19+): `atomic.Int64`, `atomic.Bool` |
| `sync.Map` | Concurrent map, read-heavy | Use `RWMutex`+map when writes dominate |
| `sync.Pool` | Reuse temporary objects | Always `Reset()` before `Put()` |
| `sync.Once` | One-time initialization | Go 1.21+: `OnceFunc`, `OnceValue`, `OnceValues` |
| `sync.WaitGroup` | Wait for goroutine completion | `Add` before `go`; Go 1.24+: `wg.Go()` |
| `x/sync/singleflight` | Deduplicate concurrent calls | Cache stampede prevention |
| `x/sync/errgroup` | Goroutine group + errors | `SetLimit(n)` replaces hand-rolled worker pools |

### Checklist

- [ ] How will it exit?
- [ ] Can I signal it to stop?
- [ ] Can I wait for it?
- [ ] Who owns the channels?
- [ ] Should this be synchronous instead?

## Watch for

| Mistake | Fix |
| --- | --- |
| Fire-and-forget goroutine | Provide stop mechanism (context, done channel) |
| Closing channel from receiver | Only the sender closes |
| `time.After` in hot loop | Reuse `time.NewTimer` + `Reset` |
| Missing `ctx.Done()` in select | Always select on context |
| Unbounded goroutine spawning | `errgroup.SetLimit(n)` or semaphore |
| Sharing pointer via channel | Send copies or immutable values |
| `wg.Add` inside goroutine | `Add` before `go` — `Wait` may return early |
| Forgetting `-race` in CI | Always run `go test -race ./...` |
| Mutex held across I/O | Keep critical sections short |

## Reference (deep)

- [Channels and Select Patterns](./references/channels-and-select.md)
- [Sync Primitives Deep Dive](./references/sync-primitives.md)
- [Pipelines and Worker Pools](./references/pipelines.md) — fan-out/fan-in, bounded workers, generators, Go 1.23+ iterators

## Cross-references

- → See `go-performance` for false sharing, cache-line padding, `sync.Pool` hot paths
- → See `go-context` for cancellation propagation and timeouts
- → See `go-safety` for concurrent map access and race prevention
- → See `go-troubleshooting` for debugging goroutine leaks and deadlocks
- → See `go-patterns` for graceful shutdown patterns
