---
name: go-observability
description: "Observe Go services with five signals — logs (slog), metrics (Prometheus), traces (OpenTelemetry), profiles (pprof/Pyroscope), and RUM. Use when instrumenting new code, reviewing a PR's instrumentation changes, auditing observability coverage, migrating from zap/logrus/zerolog to slog, or adding GDPR/CCPA-compliant event tracking. Not for temporary performance deep-dives (see go-performance)."
license: MIT
---

# Go Observability

**Leading word: observe.** A feature is not done until it is **observe**able: metrics declared, logs structured, spans created, alerts wired. Five complementary signals answer different questions — logs (what happened), metrics (how much), traces (where the time went), profiles (why slow), RUM (how users experience it). The discipline is to make every shipped feature answer all five.

## Steps — instrument code

1. **Pick the signal that answers the question.** Route each need through the five-signals table in Reference: alerting on rate/latency → metrics; debugging one request → logs + traces; hotspot hunting → profiles.

   *Done when: the chosen signal answers the question the table says it answers.*

2. **Log structured with context.** Use `log/slog` with key-value pairs and JSON output. Pick levels deliberately: Debug for development, Info for normal ops, Warn for degraded states, Error for failures needing attention. Use `slog.InfoContext(ctx, ...)` so logs carry trace correlation.

   *Done when: no freeform string logging remains and every log call that has one passes its context.*

3. **Declare metrics with bounded cardinality.** Counter for rate of change, Gauge for snapshots, Histogram for latency. Never use unbounded values (user IDs, full URLs) as labels. Write the PromQL and alert intent as comments above each metric declaration.

   *Done when: every endpoint has latency and error-rate metrics, every label is bounded, and each metric var carries its PromQL comment.*

4. **Trace meaningful operations.** Create spans for service methods, DB queries, external API calls, and queue operations; record errors with `span.RecordError()`; propagate context across service boundaries.

   *Done when: every span is opened and closed, errors are recorded on the span, and context reaches every downstream call.*

5. **Enable profiling by toggle.** Enable pprof via environment variable so you can switch it on and off without redeploying; protect it with auth and network isolation in production.

   *Done when: profiling can be enabled on demand in production without a deploy and without exposure.*

6. **Correlate the signals.** Inject `trace_id` into logs (see the `otelslog` bridge in Reference) and attach trace IDs as exemplars on histogram observations.

   *Done when: a log line can jump to its trace, and a latency spike can jump to the offending trace.*

7. **Finish with dashboards and alerts.** Wire the PromQL from your metric comments into Grafana dashboards and Prometheus alert rules; use [awesome-prometheus-alerts](https://samber.github.io/awesome-prometheus-alerts/) as a starting point for infrastructure and dependency rules.

   *Done when: the feature's PromQL is queryable in a dashboard and alerting covers its failure modes.*

## Steps — review a PR's instrumentation

1. **Check metric coverage** — new endpoints have latency and error-rate metrics; every label is bounded. *Done when: no endpoint or dependency call ships without a latency and error metric.*
2. **Check tracing** — spans opened and closed, errors recorded, context propagated to all downstream calls. *Done when: the new call graph has a span at each service boundary.*
3. **Check logging** — structured key-value pairs, context variants used, no PII, errors logged XOR returned (never both). *Done when: each error path either returns with context or logs once at the top level.*
4. **Check observability debt** — the Definition of Done checklist below passes for the changed code. *Done when: the checklist is empty for the diff.*

## Steps — audit observability coverage

1. **Cover each signal in parallel.** Launch up to 5 parallel sub-agents, one per signal (metrics, logging, tracing, profiling, RUM), to check coverage across the codebase.

   *Done when: every signal's audit report is in, and findings are deduplicated.*

2. **Run the Definition of Done checklist** against the whole codebase and prioritize gaps by user impact.

   *Done when: every gap is filed, with the signal and service named.*

## Reference

### The five signals

| Signal | Question it answers | Tool | When to use |
| --- | --- | --- | --- |
| Logs | What happened? | `log/slog` | Discrete events, errors, audit trails |
| Metrics | How much / how fast? | Prometheus client | Aggregated measurements, alerting, SLOs |
| Traces | Where did time go? | OpenTelemetry | Request flow across services, latency breakdown |
| Profiles | Why is it slow / using memory? | pprof, Pyroscope | CPU hotspots, memory leaks, lock contention |
| RUM | How do users experience it? | PostHog, Segment | Product analytics, funnels, session replay |

### Logs + Traces: `otelslog` bridge

```go
import "go.opentelemetry.io/contrib/bridges/otelslog"

logger := otelslog.NewHandler("my-service")
slog.SetDefault(slog.New(logger))

// every call with context includes trace correlation
slog.InfoContext(ctx, "order created", "order_id", orderID)
// Output includes: {"trace_id":"abc123","span_id":"def456","msg":"order created",...}
```

### Metrics + Traces: Exemplars

```go
histogram.WithLabelValues("POST", "/orders").
    Exemplar(prometheus.Labels{"trace_id": traceID}, duration)
```

### Migrating legacy loggers

`slog` is the standard library logger since Go 1.21; migrate `zap`/`logrus`/`zerolog` toward it:

1. Add `slog` with `slog.SetDefault()`.
2. During migration, route slog output through the old logger with bridge handlers: [samber/slog-zap](https://github.com/samber/slog-zap), [samber/slog-logrus](https://github.com/samber/slog-logrus), [samber/slog-zerolog](https://github.com/samber/slog-zerolog).
3. Gradually replace `zap.L().Info(...)` / `logrus.Info(...)` / `log.Info().Msg(...)` with `slog.Info(...)`.
4. Once migrated, remove the bridge handler and the old dependency.

### Definition of Done for observability

- [ ] **Metrics declared** — counters for operations/errors, histograms for latencies, gauges for saturation; PromQL and alert rules as comments above each declaration
- [ ] **Logging is proper** — structured key-value pairs with `slog`, context variants used, no PII, errors logged OR returned (never both)
- [ ] **Spans created** — every service method, DB query, and external API call has a span with attributes; errors via `span.RecordError()`
- [ ] **Dashboards and alerts exist** — the PromQL from metric comments is wired into Grafana and Prometheus; [awesome-prometheus-alerts](https://samber.github.io/awesome-prometheus-alerts/) covers infrastructure dependencies
- [ ] **RUM events tracked** — key business events tracked server-side (PostHog/Segment), identity key is `user_id` (not email), consent checked before tracking

### Signal guides

- [Structured Logging](./references/logging.md) — slog setup, levels, request correlation, `slog.InfoContext`, handlers/middleware, zap/logrus/zerolog migration
- [Metrics Collection](./references/metrics.md) — the four metric types, Histogram vs Summary, naming, PromQL-as-comments, SLO burn-rate alerting, high-cardinality labels
- [Distributed Tracing](./references/tracing.md) — spans, `otelhttp`, `span.RecordError()`, sampling, context propagation, cost optimization
- [Profiling](./references/profiling.md) — pprof on demand, secure enabling, env-var toggles, Pyroscope continuous profiling
- [Real User Monitoring](./references/rum.md) — product analytics, CDP integration, GDPR/CCPA consent, server-side tracking
- [Alerting](./references/alerting.md) — four golden signals, Go runtime alerts, severity levels, `rate` vs `irate`, `for:` duration
- [Grafana Dashboards](./references/dashboards.md) — prebuilt Go runtime dashboards and customization

## Watch for

| Mistake | Fix |
| --- | --- |
| Log AND return the same error | Log once at the top level, return with context (`fmt.Errorf("...: %w", err)`) |
| High-cardinality labels (user IDs, full URLs) | Bounded label values only |
| Dropping context on calls | `QueryContext`, `slog.InfoContext`, propagate the span |
| Summary for latency metrics | Histogram + `histogram_quantile()` in PromQL |
| Shipping a feature unobserved | Run the Definition of Done checklist |
| Freeform string logging | Structured key-value pairs with `slog` |
| PII or emails in logs/labels | Scrub PII; use `user_id`, check consent |
| pprof exposed without auth | Auth + network isolation; env-var toggle |

## Cross-references

- → See `go-context` for propagating trace context across service boundaries
- → See `go-troubleshooting` for using observability signals to diagnose production issues
- → See `go-safety` for the single handling rule (log XOR return)
- → See `go-security` for protecting pprof endpoints and avoiding PII in logs
- → See `go-performance` for benchmarking methodology and profile interpretation
- → See `samber/cc-skills@promql-cli` for exploring PromQL expressions from the CLI
