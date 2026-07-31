---
name: go-performance
description: "Golang performance optimization, benchmarking, profiling, and measurement. Covers allocation reduction, CPU efficiency, memory layout, GC tuning, pooling, caching, hot-path optimization, writing/running Go benchmarks (b.Loop()), profiling with pprof, interpreting CPU/memory/trace profiles, comparing results with benchstat, CI benchmark regression detection, and investigating production performance with Prometheus runtime metrics. Use when profiling or benchmarks have identified a bottleneck and you need the right optimization pattern, when writing or analyzing benchmarks, or when performing performance code review. Not for debugging workflow (see go-troubleshooting skill)."
user-invocable: true
license: MIT
compatibility: Designed for Claude Code or similar AI coding agents, and for projects using Golang.
metadata:
  author: samber
  version: "1.2.0"
  openclaw:
    emoji: "🏎️"
    homepage: https://github.com/samber/cc-skills-golang
    requires:
      bins:
        - go
        - benchstat
    install:
      - kind: go
        package: golang.org/x/perf/cmd/benchstat@latest
        bins: [benchstat]
---

**Persona:** You are a Go performance engineer. You never optimize without measuring first, and you never draw conclusions from a single benchmark run — measure, hypothesize, change one thing, re-measure with statistical rigor before claiming improvement.

**Thinking mode:** Use `ultrathink` for performance optimization, benchmark analysis, and profile interpretation. Shallow analysis misidentifies bottlenecks and misreads profiling data — deep reasoning ensures the right optimization is applied to the right problem and conclusions are statistically sound.

**Modes:**

- **Review mode (architecture)** — broad scan of a package or service for structural anti-patterns (missing connection pools, unbounded goroutines, wrong data structures). Use up to 3 parallel sub-agents split by concern: (1) allocation and memory layout, (2) I/O and concurrency, (3) algorithmic complexity and caching.
- **Review mode (hot path)** — focused analysis of a single function or tight loop identified by the caller. Work sequentially; one sub-agent is sufficient.
- **Measure mode** — write or run benchmarks to establish a baseline or validate a fix. Follow [Benchmarking & Measurement](#benchmarking--measurement) below; never skip straight to optimizing without a number to compare against.
- **Optimize mode** — a bottleneck has been identified by profiling. Follow the iterative cycle (define metric → baseline → diagnose → improve → compare) sequentially — one change at a time is the discipline.

# Go Performance Optimization

## Core Philosophy

1. **Profile before optimizing** — intuition about bottlenecks is wrong ~80% of the time. Use pprof to find actual hot spots (→ See `go-troubleshooting` skill)
2. **Allocation reduction yields the biggest ROI** — Go's GC is fast but not free. Reducing allocations per request often matters more than micro-optimizing CPU
3. **Document optimizations** — add code comments explaining why a pattern is faster, with benchmark numbers when available. Future readers need context to avoid reverting an "unnecessary" optimization

## Rule Out External Bottlenecks First

Before optimizing Go code, verify the bottleneck is in your process — if 90% of latency is a slow DB query or API call, reducing allocations won't help.

**Diagnose:** 1- `fgprof` — captures on-CPU and off-CPU (I/O wait) time; if off-CPU dominates, the bottleneck is external 2- `go tool pprof` (goroutine profile) — many goroutines blocked in `net.(*conn).Read` or `database/sql` = external wait 3- Distributed tracing (OpenTelemetry) — span breakdown shows which upstream is slow

**When external:** optimize that component instead — query tuning, caching, connection pools, circuit breakers (→ See `go-database` skill, [Caching Patterns](references/caching.md)).

## Benchmarking & Measurement

Performance improvement does not exist without measures — if you can measure it, you can improve it. This section covers the full measurement workflow: write a benchmark, run it, profile the result, compare before/after with statistical rigor, and track regressions in CI.

### Writing Benchmarks

**`b.Loop()` (Go 1.24+) — preferred.** It prevents the compiler from optimizing away the code under test — without it, the compiler can detect dead results and eliminate them, producing misleadingly fast numbers. It also excludes setup code before the loop from timing automatically.

```go
func BenchmarkParse(b *testing.B) {
    data := loadFixture("large.json") // setup — excluded from timing
    for b.Loop() {
        Parse(data)  // compiler cannot eliminate this call
    }
}
```

Existing `for range b.N` benchmarks still work but should migrate to `b.Loop()` — the old pattern requires manual `b.ResetTimer()` and a package-level sink variable to prevent dead code elimination.

**Memory tracking:**

```go
func BenchmarkAlloc(b *testing.B) {
    b.ReportAllocs() // or run with -benchmem flag
    for b.Loop() {
        _ = make([]byte, 1024)
    }
}
```

`b.ReportMetric()` adds custom metrics (e.g., throughput): `b.ReportMetric(float64(totalBytes)/b.Elapsed().Seconds(), "bytes/s")`.

**Sub-benchmarks and table-driven:**

```go
func BenchmarkEncode(b *testing.B) {
    for _, size := range []int{64, 256, 4096} {
        b.Run(fmt.Sprintf("size=%d", size), func(b *testing.B) {
            data := make([]byte, size)
            for b.Loop() {
                Encode(data)
            }
        })
    }
}
```

### Running Benchmarks

```bash
go test -bench=BenchmarkEncode -benchmem -count=10 ./pkg/... | tee bench.txt
```

| Flag                   | Purpose                                   |
| ---------------------- | ------------------------------------------ |
| `-bench=.`             | Run all benchmarks (regexp filter)        |
| `-benchmem`            | Report allocations (B/op, allocs/op)      |
| `-count=10`            | Run 10 times for statistical significance |
| `-benchtime=3s`        | Minimum time per benchmark (default 1s)   |
| `-cpu=1,2,4`           | Run with different GOMAXPROCS values      |
| `-cpuprofile=cpu.prof` | Write CPU profile                         |
| `-memprofile=mem.prof` | Write memory profile                      |
| `-trace=trace.out`     | Write execution trace                     |

**Output format:** `BenchmarkEncode/size=64-8  5000000  230.5 ns/op  128 B/op  2 allocs/op` — the `-8` suffix is GOMAXPROCS, `ns/op` is time per operation, `B/op` is bytes allocated per op, `allocs/op` is heap allocation count per op.

### Documenting Results in Commits

Paste benchstat output in the commit body when the change has a measurable performance impact. This documents _why_ an optimization was made, prevents future readers from reverting it, and lets reviewers verify the claim without re-running benchmarks.

Commit format:

```
perf(parser): reduce Parse allocations 50% with sync.Pool

Replace per-call []byte allocation with a pooled buffer.

goos: linux / goarch: amd64 / cpu: AMD Ryzen 9 5950X
          │    old     │              new               │
          │  sec/op    │  sec/op     vs base            │
Parse-32    4.592µ ± 2%  3.041µ ± 1%  -33.78% (p=0.000 n=10)

          │   old    │             new              │
          │   B/op   │   B/op     vs base           │
Parse-32   1.024Ki ± 0%  0.512Ki ± 0%  -50.00% (p=0.000 n=10)

          │ old  │            new             │
          │ allocs/op │ allocs/op  vs base    │
Parse-32   12.00 ± 0%   6.000 ± 0%  -50.00% (p=0.000 n=10)
```

**Rules:**

- Only include benchmarks directly affected by the change — strip unrelated rows
- Never paste results with `~` (no statistical significance) — the improvement cannot be claimed
- Include the hardware context line (`goos/goarch/cpu`) so results are reproducible
- Use `perf(scope):` commit type for performance-only changes

### Profiling from Benchmarks

Generate profiles directly from benchmark runs — no HTTP server needed:

```bash
# CPU profile
go test -bench=BenchmarkParse -cpuprofile=cpu.prof ./pkg/parser
go tool pprof cpu.prof

# Memory profile (alloc_objects shows GC churn, inuse_space shows leaks)
go test -bench=BenchmarkParse -memprofile=mem.prof ./pkg/parser
go tool pprof -alloc_objects mem.prof

# Execution trace
go test -bench=BenchmarkParse -trace=trace.out ./pkg/parser
go tool trace trace.out
```

For full pprof CLI reference (all commands, non-interactive mode, profile interpretation), see [pprof Reference](references/benchmark-pprof.md). For execution trace interpretation, see [Trace Reference](references/benchmark-trace.md). For statistical comparison, see [benchstat Reference](references/benchmark-benchstat.md).

### Measurement Reference Files

- **[pprof Reference](references/benchmark-pprof.md)** — Interactive and non-interactive analysis of CPU, memory, and goroutine profiles. Full CLI commands, profile types (CPU vs alloc_objects vs inuse_space), web UI navigation, and interpretation patterns. Use this to dive deep into _where_ time and memory are being spent in your code.
- **[benchstat Reference](references/benchmark-benchstat.md)** — Statistical comparison of benchmark runs with rigorous confidence intervals and p-value tests. Covers output reading, filtering old benchmarks, interleaving results for visual clarity, and regression detection. Use this when you need to prove a change made a meaningful performance difference, not just a lucky run.
- **[Trace Reference](references/benchmark-trace.md)** — Execution tracer for understanding _when_ and _why_ code runs. Visualizes goroutine scheduling, garbage collection phases, network blocking, and custom span annotations. Use this when pprof (which shows _where_ CPU goes) isn't enough — you need to see the timeline of what happened.
- **[Diagnostic Tools](references/benchmark-tools.md)** — Quick reference for ancillary tools: fieldalignment (struct padding waste), GODEBUG (runtime logging flags), fgprof (frame graph profiles), race detector (concurrency bugs), and others. Use this when you have a specific symptom and need a focused diagnostic — don't reach for pprof if a simpler tool already answers your question.
- **[Compiler Analysis](references/benchmark-compiler-analysis.md)** — Low-level compiler optimization insights: escape analysis (when values move to the heap), inlining decisions (which function calls are eliminated), SSA dump (intermediate representation), and assembly output. Use this when benchmarks show allocations you didn't expect, or when you want to verify the compiler did what you intended.
- **[CI Regression Detection](references/benchmark-ci-regression.md)** — Automated performance regression gating in CI pipelines. Covers three tools (benchdiff for quick PR comparisons, cob for strict threshold-based gating, gobenchdata for long-term trend dashboards), noisy neighbor mitigation strategies (why cloud CI benchmarks vary 5-10% even on quiet machines), and self-hosted runner tuning to make benchmarks reproducible. Use this when you want to ensure pull requests don't silently slow down your codebase.
- **[Investigation Session](references/benchmark-investigation-session.md)** — Production performance troubleshooting workflow combining Prometheus runtime metrics (heap size, GC frequency, goroutine counts), PromQL queries to correlate metrics with code changes, runtime configuration flags (GODEBUG env vars to enable GC logging), and cost warnings. Use this when production benchmarks look good but real traffic behaves differently.
- **[Prometheus Go Metrics Reference](references/benchmark-prometheus-go-metrics.md)** — Complete listing of Go runtime metrics actually exposed as Prometheus metrics by `prometheus/client_golang`. Covers 30 default metrics, 40+ optional metrics (Go 1.17+), process metrics, and common PromQL queries. Use this when setting up monitoring dashboards or writing PromQL queries for production alerts.

## Iterative Optimization Methodology

### The cycle: Define Goals → Benchmark → Diagnose → Improve → Benchmark

1. **Define your metric** — latency, throughput, memory, or CPU? Without a target, optimizations are random
2. **Write an atomic benchmark** — isolate one function per benchmark to avoid result contamination (→ See [Writing Benchmarks](#writing-benchmarks) above)
3. **Measure baseline** — `go test -bench=BenchmarkMyFunc -benchmem -count=6 ./pkg/... | tee /tmp/report-1.txt`
4. **Diagnose** — use the **Diagnose** lines in each deep-dive section to pick the right tool
5. **Improve** — apply ONE optimization at a time with an explanatory comment
6. **Compare** — `benchstat /tmp/report-1.txt /tmp/report-2.txt` to confirm statistical significance
7. **Commit** — paste the benchstat output in the commit body so reviewers and future readers see the exact improvement; follow the `perf(scope): summary` commit type
8. **Repeat** — increment report number, tackle next bottleneck

Refer to library documentation for known patterns before inventing custom solutions. Keep all `/tmp/report-*.txt` files as an audit trail.

## Decision Tree: Where Is Time Spent?

| Bottleneck | Signal (from pprof) | Action |
| --- | --- | --- |
| Too many allocations | `alloc_objects` high in heap profile | [Memory optimization](references/memory.md) |
| CPU-bound hot loop | function dominates CPU profile | [CPU optimization](references/cpu.md) |
| GC pauses / OOM | high GC%, container limits | [Runtime tuning](references/runtime.md) |
| Network / I/O latency | goroutines blocked on I/O | [I/O & networking](references/io-networking.md) |
| Repeated expensive work | same computation/fetch multiple times | [Caching patterns](references/caching.md) |
| Wrong algorithm | O(n²) where O(n) exists | [Algorithmic complexity](references/caching.md#algorithmic-complexity) |
| Lock contention | mutex/block profile hot | → See `go-concurrency` skill |
| Slow queries | DB time dominates traces | → See `go-database` skill |

## Common Mistakes

| Mistake | Fix |
| --- | --- |
| Optimizing without profiling | Profile with pprof first — intuition is wrong ~80% of the time |
| Default `http.Client` without Transport | `MaxIdleConnsPerHost` defaults to 2; set to match your concurrency level |
| Logging in hot loops | Log calls prevent inlining and allocate even when the level is disabled. Use `slog.LogAttrs` |
| `panic`/`recover` as control flow | panic allocates a stack trace and unwinds the stack; use error returns |
| `unsafe` without benchmark proof | Only justified when profiling shows >10% improvement in a verified hot path |
| No GC tuning in containers | Set `GOMEMLIMIT` to 80-90% of container memory to prevent OOM kills |
| `reflect.DeepEqual` in production | 50-200x slower than typed comparison; use `slices.Equal`, `maps.Equal`, `bytes.Equal` |

## Deep Dives

- [Memory Optimization](references/memory.md) — allocation patterns, backing array leaks, sync.Pool, struct alignment
- [CPU Optimization](references/cpu.md) — inlining, cache locality, false sharing, ILP, reflection avoidance
- [I/O & Networking](references/io-networking.md) — HTTP transport config, streaming, JSON performance, cgo, batch operations
- [Runtime Tuning](references/runtime.md) — GOGC, GOMEMLIMIT, GC diagnostics, GOMAXPROCS, PGO
- [Caching Patterns](references/caching.md) — algorithmic complexity, compiled patterns, singleflight, work avoidance
- [Production Observability](references/observability.md) — Prometheus metrics, PromQL queries, continuous profiling, alerting rules

See also [Measurement Reference Files](#measurement-reference-files) above for benchmarking, profiling, and CI regression detection.

## CI Regression Detection

Automate benchmark comparison in CI to catch regressions before they reach production. → See [CI Regression Detection](references/benchmark-ci-regression.md) for three tools (benchdiff, cob, gobenchdata), noisy neighbor mitigation, and self-hosted runner tuning.

## Cross-References

- → See `go-troubleshooting` skill for pprof setup on running services (enable, secure, capture), Delve debugger, GODEBUG flags, and root cause methodology
- → See `go-data-structures` skill for slice/map preallocation and `strings.Builder`
- → See `go-concurrency` skill for worker pools, `sync.Pool` API, goroutine lifecycle, and lock contention
- → See `go-safety` skill for defer in loops, slice backing array aliasing
- → See `go-database` skill for connection pool tuning and batch processing
- → See `go-observability` skill for everyday always-on monitoring, continuous profiling (Pyroscope), and distributed tracing (OpenTelemetry)
- → See `go-testing` skill for general testing practices
- → See `samber/cc-skills@promql-cli` skill for querying Prometheus runtime metrics in production to validate benchmark findings
