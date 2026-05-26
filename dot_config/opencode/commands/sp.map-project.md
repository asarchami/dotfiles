---
description: Generate spec/project-map.md (architecture overview with Mermaid diagrams) and spec/symbol-map.md (exported symbol index for internal/). Full regeneration every run.
---

## 1. Load skill

Use the `skill` tool to load `map-project`.

## 2. Explore

Read the project structure to understand what to map:

- Read root directory — project name, top-level files (`go.mod`, `docker-compose.yml`)
- Read `cmd/` — list binaries, read each `main.go` (first 40 lines) to understand service role
- Read `internal/` — list packages, read key files to understand each package's purpose and exports
- Read `internal/config/config.go` — identify service ports, modes
- Read `spec/glossary.md` — use canonical terms

Run `git rev-parse HEAD` to capture the current commit hash for the artifact header.

## 3. Generate project-map.md

Write `spec/project-map.md` with these 5 sections following the loaded skill's templates:

### 3a. Package/Module Map

Mermaid `mindmap` showing `cmd/` and `internal/` packages with 1-line purposes. Afterwards, a table listing each package with its full path, purpose, and key types.

### 3b. Dependency Graph

Trace import relationships. Use `go list -f '{{.Imports}}' ./internal/... ./cmd/...` to find intra-project imports. Build a Mermaid `flowchart LR` with subgraphs for layers (Services, Data, Execution, Abstraction, Config/UI).

### 3c. Service Overview

Mermaid `flowchart TB` showing the 4 binaries, their ports, upstream/downstream connections. Accompanying table with service name, binary path, port, and role.

### 3d. Data Flow

One Mermaid `sequenceDiagram` per flow path:
- **Bar ingestion**: Exchange → Bars → DB
- **Trade execution**: Trading → DB → Lua engine → Exchange
- **Backtest**: Web UI → Backtest → DB → Lua engine → DB

### 3e. Key Interfaces & Deep Modules

For each key interface (`exchange.Exchange`, `db.DB`, `lua.FunctionProvider`, `symbol.Store`, `ctrl.Controller`):
- Go code block with the interface definition
- Table of implementations (concrete + mock)
- Mermaid `classDiagram` showing relationships

## 4. Generate symbol-map.md

Write `spec/symbol-map.md` covering all `internal/` packages.

For each package, list every exported Go symbol (types, interfaces, functions, constants) with signatures and 1-line descriptions.

**Order**: packages alphabetically. Within package: Types (structs first, then interfaces), Functions, Constants.

## 5. Verify

Run `go build ./...` to confirm the project still compiles (read-only analysis shouldn't break anything, but verify).

## 6. Report

```
=== map-project complete ===
spec/project-map.md — <N> sections, <N> diagrams
spec/symbol-map.md — <N> packages, <N> symbols
Commit: <hash>
```
