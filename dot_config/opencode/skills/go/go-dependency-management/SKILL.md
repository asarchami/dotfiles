---
name: go-dependency-management
description: "Go dependency management — manage every dependency as a long-term commitment: go.mod/go.sum hygiene, semantic versioning, Minimal Version Selection, govulncheck auditing, Dependabot/Renovate, and go.work workspaces. Use when adding, removing, or upgrading dependencies, resolving version conflicts, auditing the tree for vulnerabilities, analyzing binary size, or setting up automated updates."
license: MIT
---

# Go Dependency Management

**Leading word: manage.** Every dependency is a long-term maintenance commitment. The discipline: **manage** the tree deliberately — prefer the standard library, keep go.mod and go.sum honest with `tidy` and `verify`, and audit for vulnerabilities before every release.

## Steps — add or upgrade

1. **Ask before you add.** Before `go get` introduces a new dependency, confirm with the user and check: does the standard library cover it, is the license compatible, is it maintained, are there better-known alternatives, and why is it needed. Upgrading an existing dependency (`go get -u`) needs no confirmation. Prefer packages vetted in `go-popular-libraries`.

   *Done when: every new dependency is approved with stdlib, license, and maintenance checked; routine upgrades proceed without confirmation.*

2. **Pin deliberately.** `go get pkg@version` for a specific version, `@latest` explicitly; for routine updates prefer `go get -u=patch ./...` — patches change no public API. Remove with `go get pkg@none` then `go mod tidy`.

   *Done when: every add names a version or explicit latest, and routine updates use `-u=patch`.*

3. **Install tools with `go install`.** Pin versions with `@latest` or a tag — never `@master` for tools you depend on. Keep tool versions pinned in the module via a `tools.go` with `//go:build tools` and blank imports, then `go mod tidy`.

   *Done when: tools are pinned in go.mod and never enter production code.*

## Steps — keep the module honest

1. **Tidy before every commit that touches dependencies.** `go mod tidy` adds missing modules and drops unused ones; commit `go.sum` — it records checksums so `go mod verify` can detect supply-chain tampering.

   *Done when: go.mod and go.sum are committed and tidy after every dependency change.*

2. **Vendor for hermetic builds.** `go mod vendor` when builds need no network access or reproducibility beyond checksums (CI, Docker); re-run after any dependency change and commit `vendor/`.

   *Done when: vendor/ exists, is current, and is committed whenever vendoring is used.*

## Steps — audit before release

1. **Scan for vulnerabilities.** Run `govulncheck ./...` before every release to catch known CVEs in the dependency tree.

   *Done when: govulncheck is clean on the tree being released.*

2. **Check for drift and bloat.** List outdated dependencies (`go list -u -m -json all | go-mod-outdated -update -direct`), analyze binary size with `goweight`, and understand why each module exists with `go mod why`.

   *Done when: outdated versions are reviewed and dependency bloat is accounted for.*

## Reference

### Essential commands

| Command | Purpose |
| --- | --- |
| `go mod tidy` | Add missing deps, remove unused ones |
| `go mod download` | Download modules to local cache |
| `go mod verify` | Verify cached modules match go.sum checksums |
| `go mod vendor` | Copy deps into `vendor/` |
| `go mod edit` | Edit go.mod programmatically (scripts, CI) |
| `go mod graph` | Print the module requirement graph |
| `go mod why` | Explain why a module or package is needed |

### Adding and upgrading

```bash
go get github.com/pkg/errors           # Latest version
go get github.com/pkg/errors@v0.9.1    # Specific version
go get github.com/pkg/errors@latest    # Explicitly latest
go get github.com/pkg/errors@master    # Branch pseudo-version
go get -u ./...            # Upgrade ALL deps to latest minor/patch
go get -u=patch ./...      # Upgrade to latest patch only (safer)
go get github.com/pkg@v1.5 # Upgrade one package
go get github.com/pkg/errors@none   # Mark for removal, then go mod tidy
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
```

### tools.go

```go
//go:build tools

package tools

import (
    _ "github.com/golangci/golangci-lint/cmd/golangci-lint"
    _ "golang.org/x/vuln/cmd/govulncheck"
)
```

### Quick reference

```bash
go mod init github.com/user/project
go get github.com/pkg/errors@v0.9.1
go get -u=patch ./...
go mod tidy
govulncheck ./...
go list -u -m -json all | go-mod-outdated -update -direct
goweight
go mod why -m github.com/some/module
go mod graph | modgraphviz | dot -Tpng -o deps.png
go mod verify
```

### Deep dives

- [Versioning & MVS](./references/versioning.md) — semver rules, pre-releases, Minimal Version Selection, major-version suffixes
- [Auditing Dependencies](./references/auditing.md) — govulncheck, outdated tracking, goweight, test-only vs binary deps
- [Conflicts & Resolution](./references/conflicts.md) — `replace`, `exclude`, `retract`, conflict workflows
- [Go Workspaces](./references/workspaces.md) — `go.work` for multi-module development vs monorepos
- [Automated Updates](./references/automated-updates.md) — Dependabot/Renovate, auto-merge, security updates
- [Visualizing the Graph](./references/visualization.md) — `go mod graph`, modgraphviz, bloat chains

## Watch for

| Mistake | Fix |
| --- | --- |
| Adding a dependency without confirmation | Ask first; check stdlib, license, maintenance |
| `go.sum` not committed | Commit it; `go mod verify` catches tampering |
| `go get -u ./...` for routine updates | Use `go get -u=patch ./...` |
| `@master` for tools you depend on | Pin `@latest` or a version tag |
| Shipping with known CVEs | `govulncheck ./...` before release |
| Stale go.mod after a change | `go mod tidy` before the commit |
| Blindly picking "latest" | Understand MVS — you can't just pick latest |

## Cross-references

- → See `go-continuous-integration` for Dependabot/Renovate in CI
- → See `go-security` for vulnerability scanning with govulncheck
- → See `go-popular-libraries` for vetted library recommendations
