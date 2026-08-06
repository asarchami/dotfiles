---
name: go-patterns
description: "Go patterns and anti-patterns — write the idiom and audit for smells: constructors and functional options, resource lifecycle, graceful shutdown, resilience, architecture, plus a scan checklist of code smells. Use when designing APIs, choosing a pattern, setting up graceful shutdown, applying resilience, or scanning Go code for technical debt."
license: MIT
---

# Go Patterns

**Leading word: idiom.** Go has a canonical way to do almost everything — the idiom to reach for by default. Deviations from idiom are smells: write the idiom when authoring, scan for smells when auditing. "A little copying is better than a little dependency." — Go Proverbs.

## Steps — write idiomatic patterns

1. **Choose the idiomatic constructor.** `New()` for a single primary type, `NewTypeName()` for multi-type packages; functional options (`type Option func(*Server)`, `With*` builders) so the API evolves without breaking changes; options return an error only when validation can fail; use a builder only for complex validation between configuration steps.

   *Done when: every constructor uses `New`/`NewTypeName` and functional options where the API will grow, and validation lives at construction, not runtime.*

2. **Keep the lifecycle explicit.** Avoid `init()` (runs implicitly, can't return errors, unpredictable in tests); `defer Close()` immediately after opening; prefer `runtime.AddCleanup` over `runtime.SetFinalizer`.

   *Done when: no `init()` does setup, every opened resource closes on its open line, and no finalizer is introduced.*

3. **Bound every external interaction.** Every external call has a timeout; limit pools, queues, and buffers (unbounded resources grow until they crash); retries check `ctx.Err()` between attempts via `select` on `ctx.Done()`; compile regexps once at package level; `//go:embed` static assets; compile-time interface checks (`var _ Interface = (*Type)(nil)`).

   *Done when: no external call lacks a timeout, no resource is unbounded, and no retry or regexp is recreated per call.*

4. **Handle data the Go way.** `[]byte` for mutation and I/O, `string` for display and keys (conversions allocate); iterators (1.23+) and streaming for large transfers so memory stays constant; `crypto/rand` for keys and tokens; design for testability — accept interfaces, inject dependencies, keep functions pure.

   *Done when: mutable and I/O paths use `[]byte`, secrets use `crypto/rand`, and components are testable by injection.*

5. **Panic only for bugs.** Return errors for anything a caller can handle (network failures, invalid input); panic only for violated invariants and `Must*` at init time; never panic for expected errors.

   *Done when: every panic on the diff is a bug or invariant, not an expected condition.*

## Steps — audit for smells

1. **Run the scan checklist.** Walk the anti-pattern table against the changed code — interface pollution, discarded errors, goroutine leaks, iota at 0, bool parameter soup, and the rest; full severity, detection hints, and bad/good examples in [anti-patterns.md](./references/anti-patterns.md).

   *Done when: every row in the table is checked against the changed code, not just the obvious ones.*

2. **Score each finding.** Sort by severity — security, data loss, and concurrency first, then correctness and architecture; note the file:line and the idiomatic shape to switch to.

   *Done when: each finding has a severity, a location, and a positive replacement pattern.*

## Reference

### Anti-pattern scan checklist

Use as a direct audit checklist. Full bad/good examples and severity in [anti-patterns.md](./references/anti-patterns.md).

| # | Anti-pattern | Detection hint |
|---|--------------|----------------|
| 1.1 | Interface pollution (5+ methods) | `interface` with 5+ methods |
| 1.2 | Preemptive interface (1 impl) | single production impl, no mock |
| 1.3 | Chaining interfaces | interface method returns interface |
| 1.5 | Returning interface from ctor | `func NewX() SomeInterface` |
| 2.1 | Single model (3+ tag types) | `json:`+`gorm:`+`validate:` on one struct |
| 2.2 | Logic in handlers | validation/rules inside HTTP handler |
| 2.5 | Premature DRY | shared abstraction before 3rd usage |
| 3.1 | Discarded errors | `_ = fn()` where fn returns error |
| 3.2 | Bare return | `return err` without `fmt.Errorf("...: %w", err)` |
| 3.3 | Log-and-return | same error logged AND returned |
| 3.4 | Panic for expected errors | `panic(err)` for I/O/validation |
| 3.5 | Direct error comparison | `err == sentinel` without `errors.Is` |
| 3.6 | Capitalized error string | `errors.New("Failed")` |
| 4.7 | Loop append | `for _, v := range b { a = append(a, v) }` |
| 5.1 | Goroutine leak | `go func()` without stop mechanism |
| 5.2 | Mutex across I/O | `Lock()` ... DB call ... `Unlock()` |
| 5.4 | Unbounded spawning | `go fn()` in loop without `errgroup.SetLimit` |
| 5.6 | `wg.Add` in goroutine | `wg.Add(1)` inside `go func()` body |
| 6.1 | Evergreen test | test with no assertions or can't fail |
| 6.5 | `assert.Len` then index | `require.Len` (else panics) |
| 6.6 | Missing goleak | goroutine packages without `goleak.VerifyTestMain` |
| 7.1 | `init()` for setup | `func init()` doing I/O |
| 7.2 | Mutable global state | `var x` mutated at runtime |
| 8.1 | Valid iota at 0 | `StatusActive = iota` (0 = valid) |
| 8.2 | Bool parameter soup | 2+ consecutive `bool` params |
| 8.3 | `math/rand` for secrets | `crypto/rand` |
| 9.1 | Verbose error exposure | `err.Error()` in HTTP response |
| 9.2 | No body size limit | POST without `http.MaxBytesReader` |
| 9.4 | Hardcoded secrets | API key in source — env var |

- **[Design Patterns](./references/design-patterns.md)** — full pattern guide: constructors, functional options, error flow, data handling, resource management, resilience, architecture
- **[Anti-Patterns](./references/anti-patterns.md)** — full scan checklist with severity, detection hints, and bad/good examples
- [Data Handling Patterns](./references/data-handling.md) — string/[]byte/[]rune, iterators, streaming
- [Resource Management](./references/resource-management.md) — graceful shutdown, pools, `runtime.AddCleanup`
- [Architecture Patterns](./references/architecture.md) | [Clean Architecture](./references/clean-architecture.md) | [Hexagonal](./references/hexagonal-architecture.md) | [DDD](./references/ddd.md)

## Watch for

| Mistake | Fix |
| --- | --- |
| Returning an interface from a constructor | Return the concrete type; accept interfaces |
| `init()` for setup | Explicit constructor that can return errors |
| `defer Close()` far from the open | `defer` immediately after opening |
| External call without a timeout | Set a timeout on every outbound call |
| Unbounded pools, queues, buffers | Cap every resource with `errgroup.SetLimit` or a semaphore |
| Retry without context check | Backoff via `select` on `ctx.Done()` |
| `math/rand` for keys or tokens | `crypto/rand` — `math/rand` is predictable |
| Recompiling regexps per call | Compile once at package level |
| Setting finalizers | `runtime.AddCleanup` (finalizers are unpredictable) |
| `panic` for expected errors | Return the error; panic only for violated invariants |

## Cross-references

- → See `go-safety` for error wrapping, nil traps, panic policy
- → See `go-context` for timeout and cancellation patterns
- → See `go-concurrency` for goroutine lifecycle and graceful shutdown
- → See `go-structs-interfaces` for interface design and composition
- → See `go-project-layout` for directory structure
