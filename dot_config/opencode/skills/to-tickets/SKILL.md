---
name: to-tickets
description: Break a plan, spec, or spec document into independently-grabbable vertical-slice tickets. Use when user wants to convert a plan into tickets, create implementation tickets, or break down work into tickets.
---

# To Tickets

Break a plan into independently-grabbable tickets using vertical slices (tracer bullets). Each ticket declares its **blocking edges** — the other tickets that must complete before it can start.

## Deep Module Design

When decomposing tickets, respect module boundaries identified in the spec's **Module sketch & deep module design** sections. Distinguish between:

- **Deep modules** — packages hiding significant complexity behind a narrow, stable interface (few exported symbols). Examples: `internal/exchange/`, `internal/lua/`, `internal/db/`.
- **Shallow modules** — straightforward packages with minimal hidden complexity. Examples: `internal/config/`, `internal/symbol/`.
- **Thin binaries** — `cmd/*` packages that compose deep modules rather than containing significant logic.

Ticket decomposition rules:
- Each **deep module** should be its own early ticket — built, tested, and independently demoable before any service depends on it.
- **Shallow modules** can bundle with other tickets or get their own thin ticket.
- **Thin binaries** (`cmd/*`) compose already-built deep modules.
- Never split a deep module across multiple tickets — that exposes internal complexity and undermines the narrow-API design.
- Do not bundle a deep module into a service ticket; build it first, then compose.

## Process

### 1. Gather context

Read whatever source material is provided (spec, requirements, conversation). If an existing ticket set is provided, read it to understand the current state.

### 2. Explore the codebase (optional)

If you have not already explored the codebase, do so. Use the project's domain glossary vocabulary, and respect ADRs in the area you're touching.

Look for opportunities to **prefactor** the code to make implementation easier. "Make the change easy, then make the easy change."

### 3. Draft vertical slices

Break the work into **tracer bullet** tickets.

<vertical-slice-rules>

- Each slice cuts a narrow but COMPLETE path through every layer (schema, API, UI, tests) — vertical, NOT a horizontal slice of one layer
- A completed slice is demoable or verifiable on its own
- Each slice is sized to fit in a single fresh context window
- Any prefactoring should be done first

</vertical-slice-rules>

Give each ticket its **blocking edges** — the other tickets that must complete before it can start. A ticket with no blockers can start immediately.

**Wide refactors are the exception to vertical slicing.** A **wide refactor** is one mechanical change — rename a column, retype a shared symbol — whose blast radius fans across the whole codebase, so a single edit breaks thousands of call sites at once and no vertical slice can land green. Don't force it into a tracer bullet; sequence it as **expand–contract**. First expand: add the new form beside the old so nothing breaks. Then migrate call sites in batches sized by blast radius (per package, per directory), each batch its own ticket blocked by the expand, keeping CI green batch to batch because the old form still exists. Finally contract: delete the old form once no caller remains, in a ticket blocked by every migrate batch.

Slices may be 'HITL' or 'AFK'. HITL slices require human interaction. AFK slices can be implemented and merged without human interaction. Prefer AFK over HITL where possible.

### 4. Quiz the user

Present the proposed breakdown as a numbered list. For each ticket, show:

- **Title**: short descriptive name
- **Type**: HITL / AFK — prefer AFK
- **Blocked by**: which other tickets (if any) must complete first
- **User stories covered**: which spec user stories it addresses
- **What it delivers**: the end-to-end behaviour this ticket makes work

Ask the user:
- Does the granularity feel right? (too coarse / too fine)
- Are the blocking edges correct — does each ticket only depend on tickets that genuinely gate it?
- Should any tickets be merged or split further?

Ask questions **one at a time**. For each question, provide your recommended answer. If a question can be answered by exploring the codebase, explore instead. Iterate until the user approves the breakdown.

### 5. Publish the tickets

For each approved ticket, publish a new ticket record. Publish in dependency order (blockers first).

```
### <N>. <Title>

**Type:** HITL / AFK
**Blocked by:** <ticket numbers, or "None — can start immediately">
**User stories covered:** <from spec>

### What to build

A concise description of this vertical slice. Describe the end-to-end behavior, not layer-by-layer implementation. Avoid specific file paths or code snippets — they go stale fast. Exception: if a prototype produced a snippet encoding a decision more precisely than prose (state machine, reducer, schema, type shape), inline it and note it came from a prototype. Trim to the decision-rich parts.

### Acceptance criteria

- [ ] Criterion 1
- [ ] Criterion 2
```

Include metadata at the top of the document: date, source document (`spec/specs.md`), status. Renumber all tickets sequentially. End with a `## Dependency Graph` section — use Mermaid `flowchart TD` with subgraphs grouped by phase (e.g., Foundation → Core Abstractions → Implementations → Thin Services → Remaining Services → UI & Deploy). Phase subgraphs make parallel tracks and sequential handoffs visually obvious.