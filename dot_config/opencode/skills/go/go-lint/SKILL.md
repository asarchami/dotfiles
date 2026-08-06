---
name: go-lint
description: "Go linting and code quality — gate each change with golangci-lint: config, go vet, staticcheck, revive, nolint discipline, PR review framework, quality gates (coverage, gosec, govulncheck). Use when configuring or running linters, fixing lint warnings, setting up quality gates, reviewing PRs, or auditing codebase health."
license: MIT
---

# Go Lint

**Leading word: gate.** Linting is the gate between code and main — the floor every change must clear. But the gate is a floor, not a ceiling: quality is the process of running it early and often, and the review discipline that catches what linters can't.

## Steps — set up the gate

1. **Create `.golangci.yml`.** It is the single source of truth for which linters run and how; start from the production config in [assets/.golangci.yml](./assets/.golangci.yml) (33 linters) and the linter-to-concern map in [linter-reference.md](./references/linter-reference.md).

   *Done when: `.golangci.yml` exists at the repo root, is the only lint config, and every enabled linter has a purpose.*

2. **Wire the pipeline.** `gofmt -s -d .` for formatting, `go vet ./...` for static analysis, `go test -race -count=1 -coverprofile=coverage.out ./...` for tests + race + coverage, `golangci-lint run ./...` for aggregated linting, `gosec ./...` for SAST, `govulncheck ./...` for known CVEs.

   *Done when: every command exits clean locally and the gate runs in CI.*

3. **Set the quality gates.** Coverage ≥80% (`go test -cover`), cyclomatic complexity ≤10 (`gocyclo`), function length ≤60 lines (`funlen`), duplication ≤3% (SonarQube), 0 high/medium gosec findings, 0 `go vet` warnings, 0 `gofmt` diffs.

   *Done when: every gate has a tool and a target, and the current code meets them all.*

4. **Define the nolint discipline.** Every `//nolint` names the linter and carries a justification; the `nolintlint` linter enforces both; security linters (bodyclose, sqlclosecheck) are never suppressed without a strong reason.

   *Done when: no suppression in the repo is blanket or unjustified.*

## Steps — run the gate during development

1. **Lint after every significant change** — `golangci-lint run ./...`.

   *Done when: the diff passes before it leaves your machine.*

2. **Auto-fix what you can** — `golangci-lint run --fix ./...`, then format with `golangci-lint fmt ./...`.

   *Done when: everything auto-fixable is fixed and the remaining issues are manual.*

3. **Lint only new code on legacy repos** — `issues.new-from-rev: HEAD~1` so the existing debt doesn't block the diff.

   *Done when: only the changed lines are gated, and the debt is tracked separately.*

4. **Expose it via Makefile** — `lint`, `lint-fix`, `fmt` targets so the gate is one command.

   *Done when: `make lint` reproduces the CI gate locally.*

## Steps — review PRs or audit

1. **Organize feedback by priority.** Critical (must fix): security vulns, data loss, concurrency bugs, resource leaks. Important (should fix): architecture, missing error handling, incorrect logic, test gaps. Suggestion (optional): clarity, performance tweaks, idiomatic patterns. Positive: name what's good.

   *Done when: every comment is bucketed, and each issue states What (problem), Why (risk), How (code fix).*

2. **Parallelize legacy cleanup.** Up to 5 parallel sub-agents by linter category: (1) `--fix` auto-fixables, (2) security (bodyclose, gosec), (3) error handling (errcheck, nilerr, wrapcheck), (4) style (gofumpt, revive), (5) code quality (gocritic, unused).

   *Done when: each category is owned by one agent and the results re-pass the gate.*

## Reference

### Essential pipeline

```bash
gofmt -s -d .            # check formatting (--fix to auto-correct)
go vet ./...             # static analysis
go test -race -count=1 -coverprofile=coverage.out ./...   # tests + race + coverage
golangci-lint run ./...  # aggregated linting
gosec ./...              # security SAST
govulncheck ./...        # known CVEs in dependencies
```

### golangci-lint

```bash
golangci-lint run ./...             # all configured linters
golangci-lint run --fix ./...       # auto-fix where possible
golangci-lint fmt ./...             # format (v2+)
golangci-lint run --enable-only govet ./...   # single linter
golangci-lint linters               # list available
golangci-lint migrate               # v1 → v2 config
```

### nolint discipline

```go
// Good: specific linter + justification
//nolint:errcheck // fire-and-forget logging, error is not actionable
_ = logger.Sync()

// Bad: blanket suppression without reason
//nolint
_ = logger.Sync()
```

### PR review framework

```
## Critical (must fix)      Security vulns, data loss, concurrency bugs, resource leaks
## Important (should fix)   Architecture, missing error handling, incorrect logic, test gaps
## Suggestion (optional)    Clarity, performance tweaks, idiomatic patterns
## Positive                 Well-designed abstractions, good coverage, clean naming
```

### Quality gates

| Metric | Target | Tool |
|--------|--------|------|
| Test coverage | ≥ 80% | `go test -cover` |
| Cyclomatic complexity per func | ≤ 10 | `gocyclo` |
| Function length | ≤ 60 lines | `funlen` |
| Duplication | ≤ 3% | SonarQube |
| Gosec severity | 0 high/medium | `gosec` |
| `go vet` | 0 warnings | `go vet` |
| `gofmt` | 0 diffs | `gofmt -s -d` |

SonarQube config and CI gates: see [code-quality.md](./references/code-quality.md). Full nolint patterns: [nolint-directives.md](./references/nolint-directives.md).

## Watch for

| Mistake | Fix |
| --- | --- |
| Blanket `//nolint` without reason | Name the linter and justify; let `nolintlint` enforce it |
| Suppressing security linters | Keep bodyclose, sqlclosecheck, gosec active |
| "deadline exceeded" | Raise `run.timeout` in `.golangci.yml` (default 5m) |
| Too many issues on legacy code | `issues.new-from-rev: HEAD~1` |
| Linter not found | `golangci-lint linters` — may need a newer version |
| v1 config errors after upgrade | `golangci-lint migrate` |
| Slow on large repos | Reduce `run.concurrency` or add `run.skip-dirs` |
| Linting only in CI | Run the gate locally after every significant change |

## Cross-references

- → See `go-style` for the style rules linters enforce
- → See `go-security` for SAST beyond linting (gosec, govulncheck)
- → See `go-continuous-integration` for CI pipeline with `golangci-lint-action`
- → See `go-testing` for test discipline and coverage
