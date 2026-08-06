---
name: go-modernize
description: "Upgrade Go code to modern idioms — latest language features, standard library improvements, and tooling. Use when writing or reviewing Go code to leverage current idioms, when asked about Go upgrades, migration, modernization, or deprecation, when the modernize linter reports issues, or when running a full-scan modernization across the codebase or in CI."
license: MIT
---

# Go Code Modernization

**Leading word: upgrade.** Every Go release ships safer, faster replacements for patterns the codebase still uses. The discipline is to **upgrade** continuously in safety-first priority order — correctness and security fixes first, then readability, then gradual improvement — while staying in scope and suggesting only what the current task touches.

**Scope:** This skill covers the last 3 years of Go modernization (Go 1.21 through Go 1.26, released 2023–2026). A few older improvements (`any`, `errors.Is`/`errors.As`, `strings.Cut`) are included because they are still commonly missed; pre-1.21 baseline practices are considered already-adopted and omitted. On projects targeting Go ≤1.20, modernizations may be limited — suggest the version upgrade first.

## Steps — inline (actively coding)

1. **Pin the version and the ignore list.** Read `go.mod`/`go.work` for the current Go version; read `.modernize` in the project root for previously ignored suggestions.

   *Done when: you know the target Go version and no ignored item appears in what you propose.*

2. **Suggest only relevant modernizations.** Propose changes related to the file or feature being worked on; mention other opportunities you noticed and why they'd help, but leave unrelated files untouched.

   *Done when: every suggestion applies to the code under the cursor and nothing outside it is edited.*

3. **Record ignored suggestions.** If the developer explicitly ignores a suggestion, append one line to `.modernize` (format: `<date> <category> <description>`) so it is not suggested again.

   *Done when: every explicit ignore is written to `.modernize`.*

## Steps — full scan (/go-modernize or CI)

1. **Pin the versions.** Read `go.mod`/`go.work`; check the changelog table for the latest release and suggest an upgrade if the project lags, naming the benefits it unlocks.

   *Done when: current and latest versions are known and any version gap is explicitly surfaced.*

2. **Read `.modernize`** and exclude every ignored suggestion from the scan.

   *Done when: no ignored suggestion appears in the output.*

3. **Parallelize the scan** with up to 5 sub-agents, one per category: deprecated packages and API replacements; language features (range-over-int, `min`/`max`, `any`, iterators); standard library upgrades (`slices`, `maps`, `cmp`, `slog`); testing patterns (`t.Context`, `b.Loop`, `synctest`); tooling and infra (golangci-lint v2, govulncheck, PGO, CI pipeline).

   *Done when: each category has been scanned and its findings consolidated into one list.*

4. **Run `golangci-lint` with the `modernize` linter** (v2.6.0+) if available. It originates from `golang.org/x/tools/go/analysis/passes/modernize` and is the same analysis used by `gopls` and `go fix`; see the `go-lint` skill for configuration.

   *Done when: linter findings are merged into the list and deduplicated.*

5. **Prioritize by the migration priority guide** — high (safety/correctness: loop-variable copies, `math/rand/v2`, `os.Root`, `govulncheck`, `errors.Is/As`, deprecated crypto), then medium (readability), then low (gradual improvement).

   *Done when: the top of the list is safety and correctness, not cosmetics.*

6. **Verify dependency updates before suggesting them.** Run `go mod tidy` and the test suite; ask the developer to review the dependency's changelog and release notes for breaking changes.

   *Done when: every proposed dependency change builds and passes tests.*

7. **Record ignored suggestions** to `.modernize` as in inline mode.

   *Done when: every ignore is captured for the next run.*

## Reference

### Go version changelogs

| Version | Release | Changelog |
| --- | --- | --- |
| Go 1.21 | August 2023 | <https://go.dev/doc/go1.21> |
| Go 1.22 | February 2024 | <https://go.dev/doc/go1.22> |
| Go 1.23 | August 2024 | <https://go.dev/doc/go1.23> |
| Go 1.24 | February 2025 | <https://go.dev/doc/go1.24> |
| Go 1.25 | August 2025 | <https://go.dev/doc/go1.25> |
| Go 1.26 | February 2026 | <https://go.dev/doc/go1.26> |

For versions newer than Go 1.26, consult the official Go release notes.

### `.modernize` file format

```
# Ignored modernization suggestions
# Format: <date> <category> <description>
2026-01-15 slog-migration Team decided to keep zap for now
2026-02-01 math-rand-v2 Legacy module requires math/rand compatibility
```

### Deprecated packages migration

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

### Migration priority guide

**High (safety and correctness):** remove loop-variable shadow copies (1.22+); `math/rand` → `math/rand/v2` and drop `rand.Seed` (1.22+); `os.Root` for user-supplied file paths (1.24+); run `govulncheck` (1.22+); `errors.Is`/`errors.As` instead of direct comparison (1.13+); migrate deprecated crypto packages (1.24+).

**Medium (readability and maintainability):** `interface{}` → `any` (1.18+); `min`/`max` builtins (1.21+); range over int (1.22+); `slices` and `maps` packages (1.21+); `cmp.Or` for defaults (1.22+); `sync.OnceValue`/`OnceFunc` (1.21+); `sync.WaitGroup.Go` (1.25+); `t.Context()` in tests (1.24+); `b.Loop()` in benchmarks (1.24+).

**Lower (gradual improvement):** migrate to `slog` (1.21+); adopt iterators where they simplify code (1.23+); `sort.Slice` → `slices.SortFunc` (1.21+); `strings.SplitSeq` and iterator variants (1.24+); tool deps in `go.mod` tool directives (1.24+); PGO for production builds (1.21+); golangci-lint v2 with the modernize linter (v2.6.0+); `govulncheck` in CI; a monthly modernization CI pipeline; `encoding/json/v2` for new code (1.25+, experimental); AI-driven code review in CI (see `go-continuous-integration`).

### In-depth references

- **[Go version modernizations](./references/versions.md)** — before/after examples for each Go version (1.21–1.26) and general modernizations.
- **[Tooling modernization](./references/tooling.md)** — CI tooling, govulncheck, PGO, golangci-lint v2, and AI-powered modernization pipelines.

## Watch for

| Mistake | Fix |
| --- | --- |
| Suggesting unrelated refactors while the developer codes | Stay in scope: current file or feature only; mention the rest |
| Re-suggesting an ignored modernization | Read `.modernize` first; never re-propose listed items |
| Suggesting dependency upgrades unverified | Run `go mod tidy` + tests first; review the changelog |
| Readability changes ahead of safety fixes | Follow the priority guide — safety first |
| Proposing modernizations the project's Go version can't use | Check `go.mod`; suggest the version upgrade first |
| Ignoring the scope of the codebase | Full scans in CI can exceed output limits — sub-agents per category |

## Cross-references

- → See `go-lint` for golangci-lint configuration including the `modernize` linter
- → See `go-testing` for `t.Context`, `b.Loop`, and synctest patterns
- → See `go-observability` for `slog` migration
- → See `go-continuous-integration` for govulncheck and AI-driven review in CI
- → See `go-safety` for `os.Root` and path-traversal hardening
