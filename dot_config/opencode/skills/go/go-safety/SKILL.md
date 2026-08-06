---
name: go-safety
description: "Go defensive coding and error handling — write code that can't crash or corrupt: error creation and wrapping with %w, errors.Is/As/Join, single-handling rule, panic policy, nil/map/slice traps, numeric and float pitfalls, resource lifecycle, defensive copying, zero-value design. Use when writing or reviewing code involving errors, nil-prone types, or subtle runtime bugs."
license: MIT
---

# Go Safety

**Leading word: defensive.** Write code that doesn't crash or corrupt data under normal conditions — handle errors correctly, and guard every nil, pointer, slice, and numeric edge. Security handles attackers; safety handles ourselves.

## Steps — handle errors correctly

1. **Check and wrap every returned error.** Never discard with `_`; wrap with context — `fmt.Errorf("parsing token: %w", err)`; `%w` internally, `%v` at system boundaries; error strings fully lowercase with no trailing punctuation, acronyms too.

   *Done when: no returned error is discarded or returned bare, and every new error string is lowercase.*

2. **Inspect with `errors.Is`/`errors.As`.** Never `err == sentinel` or a bare type assertion; `errors.Join` (1.20+) for independent errors.

   *Done when: no direct sentinel comparison or bare type assertion appears on the diff.*

3. **Handle each error once.** Single handling rule: an error is logged OR returned, never both — log at boundaries, wrap and return everywhere else; sentinels (`ErrPrefix`) for expected conditions, custom types to carry data; never expose technical errors to users — log details, return generic messages; keep messages low-cardinality and attach IDs/paths as structured `slog` attributes (Go 1.21+).

   *Done when: no error is both logged and returned, and no technical detail reaches the user.*

4. **Apply the panic policy.** Return errors for anything a caller can handle (network failures, invalid input); panic only for violated invariants and `Must*` at init time; recover at goroutine boundaries; never panic/recover as control flow; `defer f.Close()` without error check is acceptable.

   *Done when: every panic on the diff is a bug or invariant, and recovery sits only at goroutine boundaries.*

## Steps — write defensively

1. **Use comma-ok everywhere.** `v, ok := x.(T)` — a bare assertion panics on mismatch; a typed nil pointer in an interface is not `== nil` (the type descriptor makes it non-nil) — return untyped `nil`.

   *Done when: no bare type assertion and no typed nil can flow into an interface.*

2. **Guard the containers.** Nil maps panic on write — initialize before use or lazy-init; `append` may reuse the backing array — `a[:len(a):len(a)]` forces a copy; return `slices.Clone`/`maps.Clone` from exported functions so callers can't mutate your internals.

   *Done when: no nil map is written, no shared backing array escapes, and no internal slice/map reference is exposed.*

3. **Defend the numerics.** Integer conversions truncate silently — check bounds against `math.MaxInt32`/`MinInt32`; float arithmetic is not exact — epsilon comparison or `math/big`; guard division by zero.

   *Done when: every conversion and comparison on the diff is bounds- or epsilon-checked.*

4. **Design useful zero values.** `var x MyType` must be safe; lazy-init with `sync.Once`; use generics over `any` when the type set is known so the compiler catches mismatches; `defer` runs at function exit, not loop iteration — extract the loop body to a function.

   *Done when: every zero value is safe to use and no defer is trapped in a loop.*

## Reference

- **[Error Handling Guide](./references/error-handling-guide.md)** — full principles, best-practice summary, audit modes
- [Error Creation](./references/error-creation.md) — sentinel vs custom types, decision table
- [Error Wrapping & Inspection](./references/error-wrapping.md) — `%w` vs `%v`, `errors.Is`/`As`/`Join`
- [Error Patterns & Logging](./references/error-patterns.md) — single handling rule, panic/recover, `slog` integration
- [Nil Safety Deep Dive](./references/nil-safety.md) — nil receivers, the nil-interface trap, nil in generics
- [Slice & Map Safety](./references/slice-map-safety.md) — shared backing arrays, the append trap, memory retention, `slices.Clone`

## Watch for

| Mistake | Fix |
| --- | --- |
| Bare type assertion `v := x.(T)` | `v, ok := x.(T)` |
| Returning typed nil in an interface function | Return untyped `nil` |
| Writing to a nil map | `make(map[K]V)` or lazy-init |
| Assuming `append` always copies | `s[:len(s):len(s)]` forces a copy |
| `defer` in a loop | Extract the body to a separate function |
| `int64` → `int32` without bounds check | Guard with `math.MaxInt32`/`MinInt32` |
| Comparing floats with `==` | `math.Abs(a-b) < epsilon` |
| Integer division without zero check | Guard `if divisor == 0` |
| Returning internal slice/map reference | Return `slices.Clone`/`maps.Clone` |
| Swallowed errors / log-and-return | Check and wrap every error; log XOR return |

## Cross-references

- → See `go-patterns` for panic policy and error handling patterns
- → See `go-observability` for `slog` setup, levels, and request logging middleware
- → See `go-concurrency` for goroutine lifecycle, leaks, and sync primitives
- → See `go-data-structures` for slice/map internals and copy semantics
- → See `go-troubleshooting` for debugging panics and race conditions
