---
name: go-project-layout
description: "Layout Go projects and workspaces — directory structure, cmd/internal/pkg boundaries, go.mod naming, monorepo go.work, config files, testing layout. Use when starting a new Go project, organizing or restructuring an existing codebase, setting up a monorepo or workspace with multiple packages, creating a CLI with multiple main packages, or deciding where code should live."
license: MIT
---

# Go Project Layout

**Leading word: layout.** Structure is only worth the complexity it justifies. The discipline is to **layout** the project to match its real scope — a script stays flat, a service gains layers only when actual complexity demands them — and to ask the developer about architecture and dependency injection before scaffolding anything.

## Steps — set up a new project

1. **Ask first.** Ask the developer which software architecture they prefer (clean, hexagonal, DDD, flat). Right-size the structure to the project scope — a 100-line CLI tool gets a flat structure, not layers of abstractions or dependency injection.

   *Done when: the chosen architecture is known and the structure matches the project's real scope, not a template.*

2. **Ask about dependency injection.** Manual constructor injection, a DI library (samber/do, google/wire, uber-go/dig+fx), or none — the choice changes how services are wired, how lifecycle (health checks, graceful shutdown) is managed, and how the project is structured.

   *Done when: the DI approach is decided and reflected in the directory and wiring layout.*

3. **Choose the project type** from the table below (CLI tool, library, service, monorepo, workspace).

   *Done when: the type is named and its key directories are known.*

4. **Name and init the module.** The module path matches the repository URL, lowercase only, hyphens for multi-word (`github.com/jdoe/payment-processor` — not `myproject`, `MyProject`, or `utils`). Run `go mod init github.com/user/project-name`, then `gofmt -s -w .`.

   *Done when: the module path mirrors the repo URL and is all lowercase.*

5. **Lay out directories.** All `main` packages live in `cmd/{name}/` with minimal logic — parse flags, wire dependencies, call `Run()`. Business logic belongs in `internal/` (non-exported) or `pkg/` (only code genuinely useful to external consumers).

   *Done when: entry points are thin `cmd/` mains and `pkg/` holds only externally-consumed code.*

6. **Add essential root files.** Makefile (see `./assets/Makefile`), `.gitignore` with `/vendor/` and binary patterns, and `.golangci.yml` (see the `go-lint` skill for the recommended configuration).

   *Done when: the repo builds, tests, and lints from a single documented command.*

7. **Set up tests and workspaces.** Co-locate `_test.go` files with the code they test and use `testdata/` for fixtures. For monorepos, initialize `go work` and add the modules.

   *Done when: `go test ./...` passes and, where applicable, the workspace is synced.*

## Steps — restructure an existing codebase

1. **Ask the developer** their preferred architecture and DI approach before moving anything. *Done when: the target layout is agreed and the scope of the move is bounded.*
2. **Relocate entry points.** Any `main` package outside `cmd/` moves under `cmd/{name}/`; its body shrinks to flags, wiring, and a `Run()` call. *Done when: every binary starts from `cmd/{name}` with minimal logic.*
3. **Separate internal from pkg.** Non-exported code goes under `internal/`; `pkg/` holds only code with external consumers. *Done when: nothing in `internal/` is imported across the module boundary and `pkg/` is externally justified.*
4. **Right-size the layers.** Remove abstraction the project's complexity doesn't earn; flatten structures for scripts and small tools. *Done when: every directory and layer maps to a real need.*
5. **Verify the tree.** `go build ./...`, `go test ./...`, and `gofmt -s -w .` pass. *Done when: the restructuring leaves the tree green.*

## Reference

### Choose the project type

| Project Type | Use When | Key Directories |
| --- | --- | --- |
| **CLI Tool** | Command-line application | `cmd/{name}/`, `internal/`, optional `pkg/` |
| **Library** | Reusable code for others | `pkg/{name}/`, `internal/` for private code |
| **Service** | HTTP API, microservice, web app | `cmd/{service}/`, `internal/`, `api/`, `web/` |
| **Monorepo** | Multiple related packages/modules | `go.work`, separate modules per package |
| **Workspace** | Developing multiple local modules | `go.work`, replace directives |

### Module naming

```go
// Good
module github.com/jdoe/payment-processor
module github.com/company/cli-tool

// Bad
module myproject
module github.com/jdoe/MyProject
module utils
```

Packages are lowercase, singular, and match their directory name — see `go-style` for complete package naming conventions.

### 12-Factor App

For services, APIs, and workers: config via environment variables, logs to stdout, stateless processes, graceful shutdown, backing services as attached resources, and admin tasks as one-off commands (e.g., `cmd/migrate/`).

### Essential root files

- **Makefile** — build automation. See [Makefile template](./assets/Makefile)
- **.gitignore** — add `/vendor/` and binary patterns
- **.golangci.yml** — linter config. See the `go-lint` skill

For application configuration with Cobra + Viper → **[config reference](./references/config.md)**.

### Deep references

- **[Directory layouts](./references/directory-layouts.md)** — universal, small project, and library layouts, plus common mistakes
- **[Testing layout](./references/testing-layout.md)** — file naming, placement, and organization
- **[Workspaces](./references/workspaces.md)** — `go.work` setup, structure, and commands

## Watch for

| Mistake | Fix |
| --- | --- |
| Over-structuring a small project | Right-size layers to real complexity; a script stays flat |
| Module path not matching the repository URL | `go mod init github.com/user/project-name` |
| Business logic in `cmd/` | Thin mains: parse flags, wire dependencies, call `Run()` |
| Everything in `pkg/` | `internal/` for the rest; only externally-consumed code in `pkg/` |
| `main` packages outside `cmd/` | Move entry points under `cmd/{name}/` |
| No build/test entry point at the root | Makefile + `.gitignore` + linter config |
| Assuming architecture instead of asking | Ask the developer first |

## Cross-references

- → See `go-patterns` for detailed architecture guides with file trees and code examples
- → See `go-dependency-injection` for the DI approach comparison and wiring
- → See `go-cli` for CLI tool structure and Cobra/Viper patterns
- → See `go-lint` for golangci-lint configuration
- → See `go-continuous-integration` for CI/CD pipeline setup
- → See `go-style` for package naming conventions
