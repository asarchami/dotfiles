---
name: go-performance
description: "Go performance — measure before you optimize: writing benchmarks (b.Loop), pprof profiling, benchstat comparison, allocation reduction, CPU/memory tuning, caching. Use when writing or running benchmarks, profiling hot paths, interpreting profiles, fixing a measured bottleneck, or reviewing performance."
license: MIT
---

# Go Performance

**Leading word: measure.** Performance improvement does not exist without measures — intuition about bottlenecks is wrong ~80% of the time. The discipline is a loop, never a guess: **define metric → baseline → diagnose → improve one thing → re-measure**.

## Steps — measure, then optimize

1. **Define the metric.** Choose latency, throughput, memory, or CPU — and the caller-visible target.

   *Done when: the metric and the acceptance target are written down before any change.*

2. **Write an atomic benchmark.** One function per benchmark, isolated from contamination; `b.Loop()` (Go 1.24+) prevents dead-code elimination and auto-excludes setup.

   *Done when: the benchmark isolates the hot function and the compiler cannot eliminate it.*

3. **Take a baseline.** `go test -bench=BenchmarkMyFunc -benchmem -count=6 ./pkg/... | tee /tmp/report-1.txt`.

   *Done when: a baseline report is on disk before any optimization is applied.*

4. **Diagnose with a profile.** Find where time and allocations actually go — match the pprof signal to the bottleneck table below; rule out external bottlenecks first (if 90% of latency is a slow DB or API call, reducing allocations won't help).

   *Done when: the diagnosis names the bottleneck and the profile backs it.*

5. **Improve one thing, then re-measure.** Apply ONE optimization per iteration, each with an explanatory comment; compare with `benchstat` for statistical significance.

   *Done when: benchstat shows a real gain (no `~`), each iteration is one commented optimization.*

6. **Commit the evidence.** Paste the benchstat output in the commit body with a `perf(scope):` commit type; repeat on the next bottleneck.

   *Done when: the commit documents before/after numbers and the next bottleneck is named.*

## Steps — write a benchmark

1. **Prefer `b.Loop()`** — it prevents dead-code elimination and auto-excludes setup from timing (see [benchmark.md](./references/benchmark.md) for the migration off `for range b.N`).

   *Done when: every new benchmark loops with `b.Loop()` or justifies the old pattern.*

2. **Name and scope deliberately.** One function per benchmark, named `BenchmarkX`; use sub-benchmarks for input sizes.

   *Done when: benchmark names identify the function and each input size is a sub-benchmark.*

3. **Record and read the numbers.** Run with `-benchmem -count=10 | tee bench.txt`; interpret the output — `-8` is GOMAXPROCS, `ns/op` time per op, `B/op` bytes per op, `allocs/op` heap allocations.

   *Done when: the report file records time, bytes, and allocs, and every number is understood.*

## Steps — review performance

1. **Scan for the measured hot list.** Default `http.Client` without Transport tuning, logging in hot loops, `panic`/`recover` as control flow, `unsafe` without benchmark proof, `reflect.DeepEqual` in production, missing GC tuning in containers, and `~` results committed as gains.

   *Done when: the hot list is clean or each entry cites its benchmark.*

2. **Check optimization priorities.** Allocation reduction is the highest ROI (Go's GC is fast but not free); document every optimization with benchmark numbers so it can't be reverted; only then micro-opt CPU (inlining, cache locality, reflection avoidance).

   *Done when: every optimization on the diff targets a measured bottleneck and is commented with its numbers.*

## Reference

### Bottleneck → signal → action

| Bottleneck | Signal (from pprof) | Action |
| --- | --- | --- |
| Too many allocations | `alloc_objects` high in heap profile | [memory.md](./references/memory.md) |
| CPU-bound hot loop | function dominates CPU profile | [cpu.md](./references/cpu.md) |
| GC pauses / OOM | high GC%, container limits | [runtime.md](./references/runtime.md) |
| Network / I/O latency | goroutines blocked on I/O | [io-networking.md](./references/io-networking.md) |
| Repeated expensive work | same computation/fetch multiple times | [caching.md](./references/caching.md) |
| Wrong algorithm | O(n²) where O(n) exists | [caching.md](./references/caching.md#algorithmic-complexity) |
| Lock contention | mutex/block profile hot | → See `go-concurrency` |
| Slow queries | DB time dominates traces | → See `go-database` |

Rule out external bottlenecks first — check with `fgprof` (off-CPU time) or a goroutine profile (goroutines blocked in `net.(*conn).Read`).

- **[Benchmarking](./references/benchmark.md)** — full measurement methodology: `b.Loop()`, sub-benchmarks, flags, commit documentation
- [pprof](./references/pprof.md) | [benchstat](./references/benchstat.md) | [trace](./references/trace.md)
- [Diagnostic Tools](./references/tools.md) | [Compiler Analysis](./references/compiler-analysis.md)
- [Memory](./references/memory.md) | [CPU](./references/cpu.md) | [I/O & Networking](./references/io-networking.md)
- [Runtime Tuning](./references/runtime.md) | [Caching](./references/caching.md)
- [CI Regression Detection](./references/ci-regression.md) — benchdiff, cob, gobenchdata
- [Investigation Session](./references/investigation-session.md) | [Prometheus Go Metrics](./references/prometheus-go-metrics.md) | [Production Observability](./references/observability.md)

## Watch for

| Mistake | Fix |
| --- | --- |
| Optimizing without profiling | Profile with pprof first — intuition is wrong ~80% of the time |
| Default `http.Client` without Transport | `MaxIdleConnsPerHost` defaults to 2; set to match concurrency |
| Logging in hot loops | Log calls prevent inlining and allocate; use `slog.LogAttrs` |
| `panic`/`recover` as control flow | Panic allocates a stack trace; use error returns |
| `unsafe` without benchmark proof | Only justified when profiling shows >10% gain in a verified hot path |
| No GC tuning in containers | Set `GOMEMLIMIT` to 80-90% of container memory |
| `reflect.DeepEqual` in production | 50-200x slower; use `slices.Equal`, `maps.Equal`, `bytes.Equal` |
| Committing `~` results | `~` = no statistical significance — the improvement cannot be claimed |

## Cross-references

- → See `go-troubleshooting` for pprof on running services, Delve, GODEBUG
- → See `go-data-structures` for preallocation and `strings.Builder`
- → See `go-concurrency` for worker pools, `sync.Pool`, lock contention
- → See `go-database` for connection pool tuning and batch processing
- → See `go-observability` for continuous profiling in production
