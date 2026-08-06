---
name: go-troubleshooting
description: "Diagnose Go bugs systematically — reproduce, hypothesize, measure, and root-cause before fixing. Covers debugging methodology, common Go pitfalls, test-driven debugging, pprof setup and capture, Delve, race detection, GODEBUG tracing, and production debugging. Use when a bug, crash, deadlock, or unexpected behavior is reported, or when sweeping a codebase for latent bugs. Not for interpreting profiles or applying optimizations (see go-performance)."
license: MIT
---

# Go Troubleshooting

**Leading word: diagnose.** Treat every bug as evidence of an unverified assumption — **diagnose** the root cause before touching code. The loop is constant: Read the error → Reproduce → Measure one thing → Fix → Verify. A fix you cannot explain is a guess, and symptom fixes become new bugs under time pressure.

## Steps — diagnose a single reported issue

1. **Read the error message first.** Go errors are precise: file and line send you straight to the code; type mismatch → check signatures and interface satisfaction; "undefined" → check imports, exported names, build tags; "cannot use X as Y" → check concrete vs interface types.

   *Done when: you can point at the failing line and name the mismatch before changing anything.*

2. **Reproduce before you fix.** Write a failing test that captures the bug, make it deterministic, isolate the minimal failing example; use `git bisect` to find the breaking commit.

   *Done when: the bug reproduces on demand in a minimal, deterministic case.*

3. **Measure one thing at a time.** pprof over intuition, the race detector over reasoning, benchmarks over assumptions. Change one thing, measure, confirm — three changes at once teach you nothing.

   *Done when: you changed exactly one variable and observed its effect.*

4. **Trace to the root cause.** No workarounds: trace the data flow backwards from the symptom, question your assumptions, ask "why" five times, gather more evidence when the picture is unclear.

   *Done when: you can state why the bug happens, not just where the symptom appears.*

5. **Research the codebase, not just the diff.** Trace callers (who calls this, with what values), check upstream validation and guard clauses that may make the "bug" unreachable, and read the surrounding code (middleware, interceptors, init).

   *Done when: every flagged bug is validated against its real call sites and upstream guarantees.*

6. **Start simple, escalate tools incrementally.** `fmt.Println` and test isolation are the right first diagnostics; reach for pprof, Delve, or GODEBUG only when simpler tools are insufficient.

   *Done when: you used the simplest tool that could answer the current question.*

7. **Verify and defend against regressions.** Confirm the fix under the reproduction, then keep that reproduction as a regression test.

   *Done when: the fix resolves the reproduction and the reproduction is committed as a test.*

## Steps — sweep a codebase for latent bugs

1. **Classify by symptom** with the Decision Tree (see Reference) so each finding routes to the right diagnostic.

   *Done when: every suspect area has a symptom category and a tool.*

2. **Split the sweep by bug category.** Launch up to 5 parallel sub-agents, one per category: nil/interface, resources, error handling, races, context/slice/map.

   *Done when: each category is fully scanned and findings are deduplicated across agents.*

3. **Sweep the red-flag patterns** that signal bugs: unchecked errors, missing nil checks, concurrent map access, goroutines without clear exit, resource leaks from `defer` in loops. See [Code Review Red Flags](./references/code-review-flags.md).

   *Done when: each finding is either fixed, or filed with the upstream guarantee that protects it noted in a comment.*

## Reference

### Quick Decision Tree

```
WHAT ARE YOU SEEING?

"Build won't compile"
  → go build ./... 2>&1, go vet ./...
  → See [compilation.md](./references/compilation.md)

"Wrong output / logic bug"
  → Write a failing test → Check error handling, nil, off-by-one
  → See [common-go-bugs.md](./references/common-go-bugs.md), [testing-debug.md](./references/testing-debug.md)

"Random crashes / panics"
  → GOTRACEBACK=all ./app → go test -race ./...
  → See [common-go-bugs.md](./references/common-go-bugs.md), [diagnostic-tools.md](./references/diagnostic-tools.md)

"Sometimes works, sometimes fails"
  → go test -race ./...
  → See [concurrency-debug.md](./references/concurrency-debug.md), [testing-debug.md](./references/testing-debug.md)

"Program hangs / frozen"
  → curl localhost:6060/debug/pprof/goroutine?debug=2
  → See [concurrency-debug.md](./references/concurrency-debug.md), [pprof.md](./references/pprof.md)

"High CPU usage"
  → pprof CPU profiling
  → See [performance-debug.md](./references/performance-debug.md), [pprof.md](./references/pprof.md)

"Memory growing over time"
  → pprof heap profiling
  → See [performance-debug.md](./references/performance-debug.md), [concurrency-debug.md](./references/concurrency-debug.md)

"Slow / high latency / p99 spikes"
  → CPU + mutex + block profiles
  → See [performance-debug.md](./references/performance-debug.md), [diagnostic-tools.md](./references/diagnostic-tools.md)

"Simple bug, easy to reproduce"
  → Write a test, add fmt.Println / log.Debug
  → See [testing-debug.md](./references/testing-debug.md)
```

Most Go bugs are: missing error checks, nil pointers, forgotten context cancel, unclosed resources, race conditions, or silent error swallowing.

### Reference files

- [General Debugging Methodology](./references/methodology.md) — the systematic 10-step process and the tool-escalation guide
- [Common Go Bugs](./references/common-go-bugs.md) — nil dereferences, typed nil ≠ nil, shadowing, slice/map/defer/error/context pitfalls, races, JSON surprises, unclosed resources
- [Test-Driven Debugging](./references/testing-debug.md) — why a failing test is step one; `go test` flags for narrowing and flaky tests
- [Concurrency Debugging](./references/concurrency-debug.md) — races, deadlocks, goroutine leaks; reading `-race` output, goleak, stack dumps
- [Performance Troubleshooting](./references/performance-debug.md) — CPU workflow, heap vs alloc_objects, mutex and goroutine profiles, flamegraphs
- [pprof Reference](./references/pprof.md) — enabling endpoints (with auth), profile types, capture, interactive commands
- [Diagnostic Tools](./references/diagnostic-tools.md) — GODEBUG, Delve, escape analysis, execution tracer
- [Production Debugging](./references/production-debug.md) — debugging live systems: logs, safe pprof, tcpdump, HTTP inspection
- [Compilation Issues](./references/compilation.md) — module conflicts, CGO, version mismatch, build tags
- [Code Review Red Flags](./references/code-review-flags.md) — bug-signaling patterns to sweep for

## Watch for

| Mistake | Fix |
| --- | --- |
| "Quick fix for now, investigate later" | Root-cause first — there is no "later" |
| Multiple simultaneous changes | One hypothesis at a time |
| Proposing fixes without understanding the cause | Explain the why; gather more evidence |
| Each fix reveals a new problem | You are treating symptoms — retrace from scratch |
| 3+ fix attempts on the same issue | Wrong mental model — re-read the code, trace data flow |
| "It works on my machine" | Isolate the environmental difference |
| Blaming the framework/stdlib/compiler | It is almost never a Go bug — verify your code first |
| `fmt.Println` in production code | `slog` for production diagnostics |
| Fixing a function without checking callers | Trace callers and upstream validation first |

## Cross-references

- → See `go-concurrency` for goroutine leaks, races, and deadlocks
- → See `go-safety` for defensive coding that prevents panics
- → See `go-observability` for using logs, metrics, and traces to diagnose production issues
- → See `go-performance` for optimization after identifying a bottleneck
- → See `go-testing` for test-driven debugging and flaky-test techniques
- → See `samber/cc-skills@promql-cli` for querying Prometheus metrics during incident investigation
