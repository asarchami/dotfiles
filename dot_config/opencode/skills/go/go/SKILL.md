---
name: go
description: "Catalog of the Go skills, grouped by job: what each covers and when to reach for it. Type this name to browse the index."
license: MIT
---

# Go Skills Index

The Go skills are grouped by job. When a task touches more than one category, load the skills for each dimension (e.g. implementing a feature: `go-style`, `go-safety`, `go-lint`, `go-testing`).

## Writing & reviewing code

| Skill | Use when |
| --- | --- |
| `go-style` | Formatting, declarations, control flow, function design, identifier naming, constructors, receivers |
| `go-safety` | Error handling (wrap/Is/As/Join, single-handling rule, panic policy) and defensive coding (nil/map/append traps, numeric/float pitfalls) |
| `go-patterns` | Choosing a design pattern (functional options, resource lifecycle, resilience) or scanning for anti-patterns |
| `go-structs-interfaces` | Designing types: interface size, embedding, type assertions, receivers, struct tags, zero values |
| `go-data-structures` | Choosing containers: slice/map internals, preallocation, `container/*`, generics, copy semantics |
| `go-concurrency` | Goroutines, channels, select, locks, errgroup, worker pools, leak and race prevention |
| `go-context` | `context.Context` creation, propagation, timeouts, cancellation, values |
| `go-modernize` | Upgrading to modern Go idioms (slices/maps pkgs, errors.Join, range-over-func, PGO) |

## Tooling & lifecycle

| Skill | Use when |
| --- | --- |
| `go-lint` | golangci-lint config, go vet, nolint discipline, PR review framework, quality gates |
| `go-testing` | Writing/auditing tests: table-driven, testify, mocks, coverage, fuzzing, goleak |
| `go-performance` | Benchmarks, pprof profiling, benchstat, allocation reduction, hot-path tuning |
| `go-troubleshooting` | Debugging crashes, deadlocks, panics: pprof capture, Delve, race detector, root-cause workflow |
| `go-security` | Injection, crypto, secrets, filesystem/network safety, security tooling |
| `go-observability` | slog structured logging, Prometheus metrics, OpenTelemetry tracing, alerting |
| `go-database` | database/sql, sqlx, pgx: queries, transactions, connection pools, migrations, testing |
| `go-documentation` | godoc comments, README, CHANGELOG, example tests, API docs |
| `go-project-layout` | Directory structure, workspaces, monorepos, multi-binary layouts |
| `go-dependency-management` | go.mod, versions, MVS, go.work, vulnerability scanning, updating deps |
| `go-continuous-integration` | GitHub Actions, quality gates, Dependabot/Renovate, GoReleaser, release pipelines |
| `go-popular-libraries` | Choosing a library for a task, comparing alternatives |
| `go-dependency-injection` | DI design: manual injection, when to adopt a container (then pick the library) |
| `go-cli` | CLI architecture: flags, exit codes, I/O, signals, shell completion (non-framework) |

## Library references

| Skill | Use when the codebase imports… |
| --- | --- |
| `go-spf13-cobra` | `github.com/spf13/cobra` — CLI command tree |
| `go-spf13-viper` | `github.com/spf13/viper` — configuration layering |
| `go-stretchr-testify` | testify — assert/require/mock/suite |
| `go-swagger` | swaggo — OpenAPI/Swagger annotations and generation |
| `go-grpc` | gRPC — protobuf, interceptors, streaming, TLS |
| `go-graphql` | gqlgen / graphql-go — GraphQL servers |
| `go-google-wire` | `github.com/google/wire` — compile-time DI |
| `go-uber-dig` | `go.uber.org/dig` — reflection DI container |
| `go-uber-fx` | `go.uber.org/fx` — DI + lifecycle framework |

Samber libraries (`samber/lo`, `do`, `mo`, `ro`, `oops`, `slog-*`, `hot`) live in their own `samber` category — load `samber-*` skills there when those libraries are imported.
