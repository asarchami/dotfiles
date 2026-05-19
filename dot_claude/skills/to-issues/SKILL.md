---
name: to-issues
description: Break a plan, spec, or PRD into independently-grabbable vertical-slice issues. Use when user wants to convert a plan into issues, create implementation tickets, or break down work into issues.
---

# To Issues

Break a plan into independently-grabbable issues using vertical slices (tracer bullets).

## Deep Module Design

When decomposing slices, respect module boundaries identified in the PRD's **Module sketch & deep module design** sections. Distinguish between:

- **Deep modules** — packages hiding significant complexity behind a narrow, stable interface (few exported symbols). Examples: `internal/exchange/`, `internal/lua/`, `internal/db/`.
- **Shallow modules** — straightforward packages with minimal hidden complexity. Examples: `internal/config/`, `internal/symbol/`.
- **Thin binaries** — `cmd/*` packages that compose deep modules rather than containing significant logic.

Slice decomposition must respect these boundaries:
- Each **deep module** should be its own early slice — built, tested, and independently demoable before any service depends on it. This preserves encapsulation: callers depend on the narrow interface, never on internal complexity.
- **Shallow modules** can bundle with other slices or be their own thin slice — they lack hidden complexity so there is less value in isolating them.
- **Thin binaries** (`cmd/*`) are slices that compose already-built deep modules. Their dependencies should reference the deep module slices.
- Never split a deep module across multiple slices — that would expose internal complexity and undermine the narrow-API design.
- Do not bundle a deep module into a service slice; build it first, then compose.

## Process

### 1. Gather context

Read whatever source material is provided (PRD, spec, requirements). If an existing issue set is provided, read it to understand the current state.

### 2. Explore the codebase (optional)

If you have not already explored the codebase, do so to understand the current state of the code. Issue titles and descriptions should use the project's domain glossary vocabulary, and respect ADRs in the area you're touching.

### 3. Draft vertical slices

Break the plan into **tracer bullet** issues. Each issue is a thin vertical slice that cuts through ALL integration layers end-to-end, NOT a horizontal slice of one layer.

- Each slice delivers a narrow but COMPLETE path through every layer (schema, API, UI, tests)
- A completed slice is demoable or verifiable on its own
- Prefer many thin slices over few thick ones

Slices may be 'HITL' or 'AFK'. HITL slices require human interaction, such as an architectural decision or a design review. AFK slices can be implemented and merged without human interaction. Prefer AFK over HITL where possible.

### 4. Quiz the user

Interview the user about the proposed breakdown. Start with structural questions (merge/split/reorder, dependency changes) before drilling into individual slice details.

For each new slice needed, discuss:
- **Title**: short descriptive name
- **Scope**: end-to-end behavior, not layer-by-layer
- **Type**: HITL / AFK — prefer AFK
- **Blocked by**: which slice numbers must come first
- **User stories covered**: which PRD user stories it addresses
- **Acceptance criteria**: concrete, testable conditions

For each existing slice that needs updating, discuss only the fields that changed — do not re-interview the entire slice.

Ask questions **one at a time**. Do not batch questions. For each question, provide your recommended answer. If a question can be answered by exploring the codebase, explore instead.

### 5. Publish the issues

For each approved slice, publish a new issue record. Publish in dependency order (blockers first).

```
### <N>. <Title>

**Type:** HITL / AFK
**Blocked by:** <slice numbers, or "None">
**User stories covered:** <from source>

### What to build

A concise description of this vertical slice. Describe the end-to-end behavior, not layer-by-layer implementation. Avoid specific file paths or code snippets — they go stale fast.

### Acceptance criteria

- [ ] Criterion 1
- [ ] Criterion 2
```

Include metadata at the top of the document: date, source document, status. Renumber all slices sequentially. End with a `## Dependency Graph` section — use Mermaid `flowchart TD` with subgraphs grouped by phase (e.g., Foundation → Core Abstractions → Implementations → Thin Services → Remaining Services → UI & Deploy). Phase subgraphs make parallel tracks and sequential handoffs visually obvious.
