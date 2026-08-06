---
name: go-continuous-integration
description: "Go CI pipeline — GitHub Actions workflows for testing, linting, SAST, vulnerability scanning, dependency updates, releases, and AI review. Use when setting up a pipeline for a Go project, generating workflow or config files, or improving an existing pipeline against the stage reference."
license: MIT
---

# Go Continuous Integration

**Leading word: pipeline.** Every pipeline is a quality gate. Build and extend GitHub Actions workflows so each step earns its place on three axes — build speed, signal reliability, and security posture — and know what each stage is for before you write it.

## Steps — setup a pipeline

1. **Choose the stage order.** Generate workflows in this order: test → lint → security → release. Include only the stages the project needs — a library has no Docker stage.
   *Done when: every stage that applies has a workflow and no stage is added without a justification on the three axes.*

2. **Pin the action versions.** Use the current stable major version of each action (`actions/checkout`, `actions/setup-go`, `golangci/golangci-lint-action`, `codecov/codecov-action`, `goreleaser/goreleaser-action`) — the reference versions in the templates below may be outdated.
   *Done when: every action reference is a pinned `@vN` major matching the current release.*

3. **Build the test stage.** Adapt the Go version matrix to `go.mod`, run `go test -race -shuffle=on -coverprofile=coverage.out`, set `fail-fast: false`, add `go mod tidy && git diff --exit-code`, and enforce coverage thresholds via `codecov.yml`. Use `-count=1` in the integration workflow so cached results can't hide flaky service interactions.
   *Done when: the matrix matches go.mod, tests run with `-race` and `-shuffle=on`, one failing Go version doesn't cancel the others, a tidy check fails the build, and integration tests skip the cache.*

4. **Build the lint stage.** Run `golangci-lint` on every PR, configured per the `go-lint` skill.
   *Done when: lint.yml runs golangci-lint on each PR and `.golangci.yml` follows the go-lint configuration.*

5. **Build the security stage.** Run `govulncheck` (it reports only vulnerabilities in called code paths, unlike generic CVE scanners), add CodeQL with the extended query suite, and add Trivy container scanning if the project produces images.
   *Done when: govulncheck gates CI, CodeQL reads `.github/codeql/codeql-config.yml`, and the Docker workflow scans built images.*

6. **Set up dependency updates.** Use Dependabot with minor/patch grouped into one PR and majors split into individual PRs; gate auto-merge with the `if: github.actor == 'dependabot[bot]'` guard and rely on branch protection (required status checks + approvals) as the real safety net. Choose Renovate instead when Dependabot feels too limited.
   *Done when: an updater is enabled, auto-merge fires only for Dependabot PRs, and branch protection requires checks and approvals before merge.*

7. **Build the release stage.** Match the GoReleaser config to project type (program / library / monorepo). For image-producing projects, build multi-platform with QEMU + Buildx, set `push: false` on pull requests, scope permissions per job, and generate SBOM + provenance.
   *Done when: release triggers only on `v*` tag pushes, the image job never pushes from a PR, and each job's `permissions` block covers only what that job does.*

8. **Hand off repository settings.** Tell the developer to configure branch protection, workflow permissions, secrets, and environments per repo-security.md, and add AI review for correctness and security.
   *Done when: the repo-security checklist is handed off and AI review is in place — or explicitly skipped for cost.*

## Steps — improve an existing pipeline

1. **Read current workflow files first.** Identify gaps against the stage map before proposing anything.
   *Done when: every existing step is accounted for and each gap is named against the reference table.*

2. **Propose targeted additions.** Add only missing quality gates; never duplicate a step that already exists.
   *Done when: the diff adds gates, not duplicates, and each proposal is justified on speed, signal, or security.*

## Reference

### Stage map

| Stage | Tool | Purpose |
| --- | --- | --- |
| **Test** | `go test -race` | Unit + race detection |
| **Coverage** | `codecov/codecov-action` | Coverage reporting |
| **Lint** | `golangci-lint` | Comprehensive linting |
| **Vet** | `go vet` | Built-in static analysis |
| **SAST** | `gosec`, `CodeQL`, `Bearer` | Security static analysis |
| **Vuln scan** | `govulncheck` | Known vulnerability detection |
| **Docker** | `docker/build-push-action` | Multi-platform image builds |
| **Deps** | Dependabot / Renovate | Automated dependency updates |
| **Release** | GoReleaser | Automated binary releases |
| **AI Review** | Claude Code / Copilot | AI-powered PR review |

### Templates

- **Testing** — `./assets/test.yml`, `./assets/integration.yml` (`-count=1`), `./assets/codecov.yml`
- **Linting** — `./assets/lint.yml`; configure `.golangci.yml` per the `go-lint` skill
- **Security** — `./assets/security.yml`, `./assets/codeql-config.yml`; Trivy lives in `./assets/docker.yml`
- **Dependencies** — `./assets/dependabot.yml`, `./assets/dependabot-auto-merge.yml`, `./assets/renovate.json`
- **Release** — `./assets/release.yml`, `./assets/goreleaser-cli.yml`, `./assets/goreleaser-lib.yml`, `./assets/goreleaser-monorepo.yml`, `./assets/docker.yml`
- **AI review** — `./assets/claude-code-review.yml`, `./assets/copilot-review-instructions.md`
- **Repo settings** — `./references/repo-security.md`

### CodeQL query suites

| Suite | Coverage |
| --- | --- |
| `default` | Standard security queries |
| `security-extended` | Extra security queries, slightly lower precision |
| `security-and-quality` | Security plus maintainability and reliability |

### Docker workflow details

- **QEMU + Buildx**: required for multi-platform builds (`linux/amd64,linux/arm64`); drop platforms you don't need.
- **`push: false` on PRs**: images are built but never pushed on pull requests — validates the Dockerfile without publishing untrusted code.
- **Metadata action**: generates semver tags (`v1.2.3` → `1.2.3`, `1.2`, `1`), branch tags, and SHA tags.
- **Provenance + SBOM**: `provenance: mode=max` and `sbom: true` need `attestations: write` and `id-token: write`.
- **Dual registry**: GHCR via `GITHUB_TOKEN` (no secret needed) + Docker Hub via `DOCKERHUB_USERNAME`/`DOCKERHUB_TOKEN` secrets — never hardcode credentials; drop the Docker Hub login/image lines for GHCR-only.

### Renovate advantages over Dependabot

- `gomodTidy`: runs `go mod tidy` after updates
- Native automerge — no separate workflow
- More flexible grouping of PRs
- Regex managers for Dockerfiles, Makefiles, etc.
- Monorepo support: Go workspaces and multi-module repos

### Claude Code review jobs

| Job | Areas | Priority |
| --- | --- | --- |
| `quality` | Code style, Naming, Documentation, Design patterns | Suggestion-first |
| `correctness` | Error handling, Code safety, Concurrency | Blocking-first |
| `security` | Security, Dependencies | Blocking-first |
| `quality-depth` | Tests, Performance, Observability, Modernize | Mixed |

AI review agents run concurrently per PR — for cost control, drop jobs you don't need or raise the PR trigger filter to specific branches.

## Watch for

| Mistake | Fix |
| --- | --- |
| Missing `-race` in CI tests | Run `go test -race` |
| No `-shuffle=on` | Randomize test order to catch inter-test dependencies |
| Caching integration test results | Use `-count=1` to disable caching |
| `go mod tidy` not checked | Add `go mod tidy && git diff --exit-code` |
| Missing `fail-fast: false` | One Go version failing shouldn't cancel other jobs |
| Not pinning action versions | Pin major versions (`@vN`, never `@master`) |
| No `permissions` block | Follow least-privilege per job |
| Ignoring govulncheck findings | Fix, or suppress with a written justification |
| No AI review in CI | Add Claude Code or Copilot — catches issues static analysis misses |

## Cross-references

- → See `go-lint` for the `.golangci.yml` configuration
- → See `go-security` for gosec, CodeQL, and vulnerable-code patterns
- → See `go-testing` for test design that survives in CI
- → See `go-dependency-management` for dependency hygiene and vulnerability scanning
- → See `go-modernize` for keeping CI aligned with current Go idioms
