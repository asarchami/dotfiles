---
description: Diff spec/requirements.md vs spec/prd.md, interview delta, update both
---

## 1. Load PRD

Read `spec/prd.md`. Store `###` sections + 12-dimension checkboxes.

## 2. Load requirements

Read `spec/requirements.md`. Extract `##` sections + `- [...]` items.

## 3. Load to-prd skill

`skill` → `to-prd`.

## 4. Diff

### 4a. One-time migration

PRD prose bullets → `- [x]`. Dimensions: acceptance criteria, NFR, edge cases, out of scope.

### 4b. Classify

| Req state | Action |
|---|---|
| `[x]` + PRD match | Skip |
| `[x]` no PRD | Interview (rare) |
| `[ ]` | Interview |
| `[~]` | Interview |

No items → confirm up-to-date, exit.

## 5. Impact

Per item, classify affected PRD sections:

| Type | Meaning |
|---|---|
| Direct conflict | Suppresses PRD |
| Implied change | Forces other dimension changes |
| Dependency | PRD must be true |
| Unaffected | Skip |

Compile discussion list.

## 6. Interview

to-prd dimensions. One question at a time. Foundation first.

- **New sections** → clarify 12 dimensions
- **Superseded** → confirm replace, mark old `[~]`, assess ripple, add `[ ]`
- **Impacted** → only changed dimensions

Codebase answers → explore. Provide recommendation per question.

## 7. Update

### 7a. spec/prd.md

- Preserve sections. Update changed fields.
- Add new `###` with 12 dimensions.
- Checkbox: `[x]` pre-existing spec, `[ ]` spec'd in this pass (needs issue breakdown), `[~]` superseded.
- For superseded old items: keep them in the file as `[~]` so the diff with `spec/issues.md` can catch them.
- Tracked: acceptance criteria, NFR, edge cases, out of scope.
- Update `## Open Questions`. Metadata: source + status.
- No extra commentary. Overwrite.

### 7b. spec/requirements.md

- `[ ]`→`[x]` for promoted items.
