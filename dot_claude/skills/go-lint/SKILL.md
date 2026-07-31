---
name: go-lint
description: "Provides linting best practices, golangci-lint configuration, and code modernization guidance for Go projects. Covers running linters, configuring .golangci.yml, suppressing warnings with nolint directives, interpreting lint output, managing linter settings, and continuously modernizing code to use the latest language features, standard library improvements, and idiomatic patterns. Use this skill whenever the user runs linters, configures golangci-lint, asks about lint warnings or suppressions, sets up code quality tooling, asks which linters to enable, asks about Go upgrades/migration/modernization/deprecation, or when the modernize linter reports issues. Also use when the user mentions golangci-lint, go vet, staticcheck, revive, or any Go linting tool. Trigger proactively when you notice old-style Go patterns that have modern replacements."
user-invocable: true
license: MIT
compatibility: Designed for Claude Code or similar AI coding agents, and for projects using Golang.
metadata:
  author: samber
  version: "1.2.0"
  openclaw:
    emoji: "🧹"
    homepage: https://github.com/samber/cc-skills-golang
    requires:
      bins:
        - go
        - golangci-lint
    install:
      - kind: brew
        formula: golangci-lint
        bins: [golangci-lint]
---

<!-- markdownlint-disable ol-prefix -->

**Persona:** You are a Go code quality engineer. You treat linting and modernization as first-class parts of the development workflow — not post-hoc cleanup steps. You prioritize safety and correctness fixes first, then readability, then gradual improvements.

**Modes:**

- **Setup mode** — configuring `.golangci.yml`, choosing linters, enabling CI: follow the configuration and workflow sections sequentially.
- **Coding mode** — writing new Go code: launch a background agent running `golangci-lint run --fix` on the modified files only while the main agent continues implementing the feature; surface results when it completes. Suggest only modernizations relevant to the current file or feature; mention other opportunities you noticed but do not touch unrelated files.
- **Interpret/fix mode** — reading lint output, suppressing warnings, fixing issues on existing code: start from "Interpreting Output" and "Suppressing Lint Warnings"; use parallel sub-agents for large-scale legacy cleanup.
- **Full modernization scan** (explicit invocation or CI): use up to 5 parallel sub-agents — Agent 1 scans deprecated packages and API replacements, Agent 2 scans language feature opportunities (range-over-int, min/max, any, iterators), Agent 3 scans standard library upgrades (slices, maps, cmp, slog), Agent 4 scans testing patterns (t.Context, b.Loop, synctest), Agent 5 scans tooling and infra (golangci-lint v2, govulncheck, PGO, CI pipeline) — then consolidate and prioritize by the [Migration Priority Guide](#migration-priority-guide).

# Go Linting & Modernization

## Overview

`golangci-lint` is the standard Go linting tool. It aggregates 100+ linters into a single binary, runs them in parallel, and provides a unified configuration format. Run it frequently during development and always in CI.

Every Go project MUST have a `.golangci.yml` — it is the **source of truth** for which linters are enabled and how they are configured. See the [recommended configuration](./assets/.golangci.yml) for a production-ready setup with 33 linters enabled.

## Quick Reference

```bash
# Run all configured linters
golangci-lint run ./...

# Auto-fix issues where possible
golangci-lint run --fix ./...

# Format code (golangci-lint v2+)
golangci-lint fmt ./...

# Run a single linter only
golangci-lint run --enable-only govet ./...

# List all available linters
golangci-lint linters

# Verbose output with timing info
golangci-lint run --verbose ./...
```

## Configuration

The [recommended .golangci.yml](./assets/.golangci.yml) provides a production-ready setup with 33 linters. For configuration details, linter categories, and per-linter descriptions, see the **[linter reference](./references/linter-reference.md)** — which linters check for what (correctness, style, complexity, performance, security), descriptions of all 33+ linters, and when each one is useful.

## Suppressing Lint Warnings

Use `//nolint` directives sparingly — fix the root cause first.

```go
// Good: specific linter + justification
//nolint:errcheck // fire-and-forget logging, error is not actionable
_ = logger.Sync()

// Bad: blanket suppression without reason
//nolint
_ = logger.Sync()
```

Rules:

1. **//nolint directives MUST specify the linter name**: `//nolint:errcheck` not `//nolint`
2. **//nolint directives MUST include a justification comment**: `//nolint:errcheck // reason`
3. **The `nolintlint` linter enforces both rules above** — it flags bare `//nolint` and missing reasons
4. **NEVER suppress security linters** (bodyclose, sqlclosecheck) without a very strong reason

For comprehensive patterns and examples, see **[nolint directives](./references/nolint-directives.md)** — when to suppress, how to write justifications, patterns for per-line vs per-function suppression, and anti-patterns.

## Development Workflow

1. **Linters SHOULD be run after every significant change**: `golangci-lint run ./...`
2. **Auto-fix what you can**: `golangci-lint run --fix ./...`
3. **Format before committing**: `golangci-lint fmt ./...`
4. **Incremental adoption on legacy code**: set `issues.new-from-rev` in `.golangci.yml` to only lint new/changed code, then gradually clean up old code

Makefile targets (recommended):

```makefile
lint:
	golangci-lint run ./...

lint-fix:
	golangci-lint run --fix ./...

fmt:
	golangci-lint fmt ./...
```

For CI pipeline setup (GitHub Actions with `golangci-lint-action`), see the `go-continuous-integration` skill.

## Interpreting Output

Each issue follows this format:

```
path/to/file.go:42:10: message describing the issue (linter-name)
```

The linter name in parentheses tells you which linter flagged it. Use this to:

- Look up the linter in the [reference](./references/linter-reference.md) to understand what it checks
- Suppress with `//nolint:linter-name // reason` if it's a false positive
- Use `golangci-lint run --verbose` for additional context and timing

## Common Issues

| Problem | Solution |
| --- | --- |
| "deadline exceeded" | Increase `run.timeout` in `.golangci.yml` (default: 5m) |
| Too many issues on legacy code | Set `issues.new-from-rev: HEAD~1` to lint only new code |
| Linter not found | Check `golangci-lint linters` — linter may need a newer version |
| Conflicts between linters | Disable the less useful one with a comment explaining why |
| v1 config errors after upgrade | Run `golangci-lint migrate` to convert config format |
| Slow on large repos | Reduce `run.concurrency` or exclude directories in `run.skip-dirs` |

## Parallelizing Legacy Codebase Cleanup

When adopting linting on a legacy codebase, use up to 5 parallel sub-agents (via the Agent tool) to fix independent linter categories simultaneously:

- Sub-agent 1: Run `golangci-lint run --fix ./...` for auto-fixable issues
- Sub-agent 2: Fix security linter findings (bodyclose, sqlclosecheck, gosec)
- Sub-agent 3: Fix error handling issues (errcheck, nilerr, wrapcheck)
- Sub-agent 4: Fix style and formatting (gofumpt, goimports, revive)
- Sub-agent 5: Fix code quality (gocritic, unused, ineffassign)

---

## Code Modernization

Continuously modernize Go codebases by replacing outdated patterns with their modern equivalents.

**Scope**: This covers the last 3 years of Go modernization (Go 1.21 through Go 1.26, released 2023-2026). While usable for projects targeting Go 1.20 or older, modernization suggestions may be limited for those versions — for best results, upgrade the Go version first. Some older modernizations (e.g., `any` instead of `interface{}`, `errors.Is`/`errors.As`, `strings.Cut`) are included because they are still commonly missed, but many pre-1.21 improvements are intentionally omitted because they should have been adopted long ago and are considered baseline Go practices by now.

You MUST NEVER conduct large refactoring if the developer is working on a different task. But TRY TO CONVINCE your human it would improve the code quality.

### Modernization Workflow

When invoked:

1. **Check the project's `go.mod` or `go.work`** to determine the current Go version (`go` directive)
2. **Check the latest Go version** using the Go Version Changelogs table below and suggest upgrading if the project's `go.mod` is behind
3. **Read `.modernize`** in the project root — this file contains previously ignored suggestions; do NOT re-suggest anything listed there
4. **Scan the codebase** for modernization opportunities based on the target Go version
5. **Run `golangci-lint`** with the `modernize` linter (see [Using the modernize linter](#using-the-modernize-linter))
6. **Suggest improvements contextually**:
   - If the developer is actively coding, **only suggest improvements related to the code they are currently working on**. Do not refactor unrelated files. Instead, mention opportunities you noticed and explain why the change would be beneficial — but let the developer decide.
   - If invoked explicitly or in CI, scan and suggest across the entire codebase.
7. **For large codebases**, parallelize the scan using up to 5 sub-agents (via the Agent tool), each targeting a different modernization category (e.g. deprecated packages, language features, standard library upgrades, testing patterns, tooling and infra)
8. **Before suggesting a dependency update**, run `go mod tidy` and the test suite to verify compatibility. Ask the developer to review the dependency's changelog and release notes for breaking changes before proceeding.
9. **If the developer explicitly ignores a suggestion**, write a short memo to `.modernize` in the project root so it is not suggested again. Format: one line per ignored suggestion, with a short description.

#### `.modernize` file format

```
# Ignored modernization suggestions
# Format: <date> <category> <description>
2026-01-15 slog-migration Team decided to keep zap for now
2026-02-01 math-rand-v2 Legacy module requires math/rand compatibility
```

### Go Version Changelogs

Reference the relevant changelog when suggesting a modernization:

| Version | Release       | Changelog                   |
| ------- | ------------- | --------------------------- |
| Go 1.21 | August 2023   | <https://go.dev/doc/go1.21> |
| Go 1.22 | February 2024 | <https://go.dev/doc/go1.22> |
| Go 1.23 | August 2024   | <https://go.dev/doc/go1.23> |
| Go 1.24 | February 2025 | <https://go.dev/doc/go1.24> |
| Go 1.25 | August 2025   | <https://go.dev/doc/go1.25> |
| Go 1.26 | February 2026 | <https://go.dev/doc/go1.26> |

For versions newer than Go 1.26, consult the official Go release notes.

When the project's `go.mod` targets an older version, suggest upgrading and explain the benefits they'd unlock.

### Using the modernize linter

The `modernize` linter (available since **golangci-lint v2.6.0**) automatically detects code that can be rewritten using newer Go features. It originates from `golang.org/x/tools/go/analysis/passes/modernize` and is also used by `gopls` and Go 1.26's rewritten `go fix` command. Enable it in `.golangci.yml` alongside the other [recommended linters](#configuration).

### Version-specific modernizations

For detailed before/after examples for each Go version (1.21–1.26) and general modernizations, see [Go version modernizations](references/modernize-versions.md).

### Tooling modernization

For CI tooling, govulncheck, PGO, golangci-lint v2, and AI-powered modernization pipelines, see [Tooling modernization](references/modernize-tooling.md).

### Deprecated Packages Migration

| Deprecated | Replacement | Since |
| --- | --- | --- |
| `math/rand` | `math/rand/v2` | Go 1.22 |
| `crypto/elliptic` (most functions) | `crypto/ecdh` | Go 1.21 |
| `reflect.SliceHeader`, `StringHeader` | `unsafe.Slice`, `unsafe.String` | Go 1.21 |
| `reflect.PtrTo` | `reflect.PointerTo` | Go 1.22 |
| `runtime.GOROOT()` | `go env GOROOT` | Go 1.24 |
| `runtime.SetFinalizer` | `runtime.AddCleanup` | Go 1.24 |
| `crypto/cipher.NewOFB`, `NewCFB*` | AEAD modes or `NewCTR` | Go 1.24 |
| `golang.org/x/crypto/sha3` | `crypto/sha3` | Go 1.24 |
| `golang.org/x/crypto/hkdf` | `crypto/hkdf` | Go 1.24 |
| `golang.org/x/crypto/pbkdf2` | `crypto/pbkdf2` | Go 1.24 |
| `testing/synctest.Run` | `testing/synctest.Test` | Go 1.25 |
| `crypto.EncryptPKCS1v15` | OAEP encryption | Go 1.26 |
| `net/http/httputil.ReverseProxy.Director` | `ReverseProxy.Rewrite` | Go 1.26 |

### Migration Priority Guide

When modernizing a codebase, prioritize changes by impact:

**High priority (safety and correctness)**

1. Remove loop variable shadow copies _(Go 1.22+)_ — prevents subtle bugs
2. Replace `math/rand` with `math/rand/v2` _(Go 1.22+)_ — remove `rand.Seed` calls
3. Use `os.Root` for user-supplied file paths _(Go 1.24+)_ — prevents path traversal
4. Run `govulncheck` _(Go 1.22+)_ — catch known vulnerabilities
5. Use `errors.Is`/`errors.As` instead of direct comparison _(Go 1.13+)_
6. Migrate deprecated crypto packages _(Go 1.24+)_ — security critical

**Medium priority (readability and maintainability)**

7. Replace `interface{}` with `any` _(Go 1.18+)_
8. Use `min`/`max` builtins _(Go 1.21+)_
9. Use `range` over int _(Go 1.22+)_
10. Use `slices` and `maps` packages _(Go 1.21+)_
11. Use `cmp.Or` for default values _(Go 1.22+)_
12. Use `sync.OnceValue`/`sync.OnceFunc` _(Go 1.21+)_
13. Use `sync.WaitGroup.Go` _(Go 1.25+)_
14. Use `t.Context()` in tests _(Go 1.24+)_
15. Use `b.Loop()` in benchmarks _(Go 1.24+)_

**Lower priority (gradual improvement)**

16. Migrate to `slog` from third-party loggers _(Go 1.21+)_
17. Adopt iterators where they simplify code _(Go 1.23+)_
18. Replace `sort.Slice` with `slices.SortFunc` _(Go 1.21+)_
19. Use `strings.SplitSeq` and iterator variants _(Go 1.24+)_
20. Move tool deps to `go.mod` tool directives _(Go 1.24+)_
21. Enable PGO for production builds _(Go 1.21+)_
22. Upgrade to golangci-lint v2 with modernize linter _(golangci-lint v2.6.0+)_
23. Add `govulncheck` to CI pipeline
24. Set up monthly modernization CI pipeline
25. Evaluate `encoding/json/v2` for new code _(Go 1.25+, experimental)_
26. Set up AI-driven code review in CI — loads these skills to guide review per area; see `go-continuous-integration`

## Cross-References

- → See `go-continuous-integration` skill for CI pipeline with golangci-lint-action and AI-driven code review
- → See `go-code-style` skill for style rules that linters enforce
- → See `go-security` skill for SAST tools beyond linting (gosec, govulncheck)
- → See `go-concurrency`, `go-testing`, `go-observability`, `go-error-handling` skills for version-specific modernizations in those areas
