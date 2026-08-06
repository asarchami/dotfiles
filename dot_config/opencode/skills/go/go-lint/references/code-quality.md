
> **Community default.** A company skill that explicitly supersedes `go-lint` skill takes precedence.

# Go Code Quality

Quality is not a gate — it's a process. This skill covers the tooling pipeline, review framework, and structural practices for maintaining Go codebases.

---

## Quick reference

| Layer | Tool / Practice | What it catches |
|-------|----------------|-----------------|
| Formatting | `gofmt -s -d` | Inconsistent style, unnecessary conversions |
| Static analysis | `go vet ./...` | Suspicious constructs, unreachable code, nilness |
| Linting | `golangci-lint` (40+ linters) | Bugs, style, complexity, security, performance |
| Unit tests | `go test -race -cover` | Regressions, races, untested paths |
| Security SAST | `gosec ./...` | SQL injection, hardcoded creds, weak crypto |
| Vulnerability | `govulncheck ./...` | Known CVEs in dependencies |
| Dependency | `go mod tidy`, `go mod verify` | Missing/unused deps, tampered go.sum |
| Coverage | `go tool cover -html=coverage.out` | Untested branches |
| Complexity | `gocyclo` / SonarQube | Cyclomatic complexity > 10 |
| Duplication | SonarQube / `golangci-lint` dup | Copy-pasted code blocks |
| Profiling | `pprof`, `benchstat` | CPU/memory hot spots, regressions |
| Docs | `go doc`, `golint` comments | Missing exported doc comments |

---

## Tooling pipeline

### Essential (run locally + CI)

```bash
gofmt -s -d .           # check formatting (--fix to auto-correct)
go vet ./...            # static analysis
go test -race -count=1 -coverprofile=coverage.out ./...  # tests + race + coverage
golangci-lint run ./... # aggregated linting
```

### Recommended CI gates

```yaml
# in order: fail fast
tests:    go test -race ./...
lint:     golangci-lint run ./...
security: gosec ./...
vuln:     govulncheck ./...
quality:  sonarqube scan (complexity, duplication, coverage gate)
```

### SonarQube setup

```properties
# sonar-project.properties
sonar.projectKey=my-app
sonar.sources=.
sonar.exclusions=**/*_test.go,**/vendor/**
sonar.tests=.
sonar.test.inclusions=**/*_test.go
sonar.go.coverage.reportPaths=coverage.out
```

See `go-lint` for full `.golangci.yml` config (33+ linters).

---

## Review framework

Organize PR feedback by priority:

```
## Critical (must fix before merge)
Security vulns, data loss, concurrency bugs, resource leaks

## Important (should fix)
Architecture problems, missing error handling, incorrect logic, test gaps

## Suggestion (optional)
Code clarity, performance tweaks, idiomatic patterns

## Positive
Well-designed abstractions, good test coverage, clean naming
```

For each issue, provide: **What** (problem), **Why** (risk/impact), **How** (code example fix).

### Review scope by type

| Review type | Focus areas |
|-------------|-------------|
| Full PR | Architecture, implementation, tests, security |
| Architecture | Package structure, interfaces, separation of concerns, domain boundaries |
| Test review | Test quality, coverage, behavior vs implementation, table-driven patterns |
| Single function | Implementation quality, naming, error handling, cyclomatic complexity |

---

## Structural practices

### Package organization

```
pkg/           # reusable library code
internal/      # private application code
cmd/           # entry points (main.go per binary)
migrations/    # SQL schemas
```

### Separation of concerns

```
handler/  → thin entry points (HTTP, gRPC, CLI)
service/  → business logic, no framework imports
repo/     → data access (DB, external API)
domain/   → core types, value objects, interfaces
```

Each layer uses its own models. Mapping between layers uses plain conversion functions.

### Code health metrics

| Metric | Target | Tool |
|--------|--------|------|
| Test coverage | ≥ 80% | `go test -cover` |
| Cyclomatic complexity per func | ≤ 10 | `gocyclo` |
| Function length | ≤ 60 lines | `golangci-lint` (`funlen`) |
| File length | ≤ 500 lines | `golangci-lint` |
| Duplication | ≤ 3% | SonarQube |
| Gosec severity | 0 high/medium | `gosec` |
| `go vet` | 0 warnings | `go vet` |
| `gofmt` | 0 diffs | `gofmt -s -d` |

---

## Cross-references

`go-lint` (golangci-lint config) | `go-testing` (test patterns) | `go-security` (SAST, gosec) | `go-patterns` (what to avoid) | `go-style` | `go-safety` | `go-concurrency` | `go-structs-interfaces` | `go-dependency-management` (govulncheck) | `go-continuous-integration` (CI pipeline)
