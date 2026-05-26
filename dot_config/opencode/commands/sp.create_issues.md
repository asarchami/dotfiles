---
description: Diff spec/prd.md vs spec/issues.md, interview delta, update both
---

## 1. Load inputs

Read `spec/issues.md` (if exists), `spec/prd.md`. Store slices + PRD sections.

## 2. Load to-issues skill

`skill` → `to-issues`. Provides: deep module guidance, quiz flow, publish format.

## 3. Diff

Compare PRD sections against issues slices:

| PRD state | Action |
|---|---|
| All `[x]` matching slices | Skip |
| `[ ]` present | Interview — new criteria need decomposition |
| `[~]` present | Interview — superseded may affect slices |
| New `###` section | Interview — new slices needed |

No items → confirm up-to-date, exit.
No issues.md → treat all sections as new, proceed.

## 4. Assess impact

Classify each delta item:

- **Direct conflict** — superseded PRD invalidates slice ACs → mark `[~]`
- **Implied change** — new items force other slice changes
- **Dependency** — blocked-by updates
- **Unaffected** — skip

Consolidate discussion list.

## 5. Interview (to-issues quiz flow)

Follow `to-issues` quiz flow. One question at a time. Foundation first.

Per new slice: title, scope, HITL/AFK, blocked-by, user stories, ACs.
Per impacted slice: only changed fields. Provide recommendation each question.

## 6. Update

### 6a. spec/prd.md

- `[ ]` → `[x]` with `(Issues: N, M)` annotation, e.g. `- [x] No WebSocket — REST-only for POC (Issues: 5, 6)`
- Modified during decomposition → `[~]` old, `[ ]` new

### 6b. spec/issues.md (to-issues publish format)

- Preserve existing slices, update changed fields
- Add new slices, renumber sequentially
- Metadata: date, source (`spec/prd.md`), status
- `## Dependency Graph` with Mermaid flowchart
- No extra commentary. Overwrite.
