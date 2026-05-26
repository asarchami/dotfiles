---
description: Process [ ] items in spec/user_requirements.md → update spec/requirements.md
---

## 1. Load existing spec

Read `spec/requirements.md`. Extract all `- [...]` items. Store full doc for amendment.

## 2. Load user requirements

Read `spec/user_requirements.md`. Per line checkbox prefix:

| Prefix | Action |
|--------|--------|
| `[x]`/`[~]` | Skip — frozen |
| `[ ]` → already in requirements.md | Add to `already_covered` |
| `[ ]` → genuinely new | Add to `candidates` |

If both lists empty → confirm up-to-date, exit.

## 3. Load glossary

Read `spec/glossary.md`. Extract terms for interview.

## 4. Diff

Compare candidates against existing requirements:

- **New** — no matching checkbox in spec
- **Already covered** → move to `already_covered`
- **Conflicts** — contradicts/supersedes existing req

No candidates → confirm up-to-date, exit.

### 4b. Cross-reference triage.md

Read `spec/triage.md`. Parse all `### <N>. <Title>` entries in `## Fixed`. For each candidate in `candidates`, compare title/description against triage-fixed entries:

- **Exact or clear match** → move candidate to `already_covered` with annotation: `(done via triage #N)`
- **Ambiguous/partial overlap** → keep in `candidates` but add an interview note: `CANDIDATE NOTE: may overlap with triage #N <Title> — verify during interview`
- **No match** → leave as is

## 5. Impact

Per candidate, classify affected requirements:

| Classification | Meaning |
|---|---|
| Direct conflict | Supersedes existing req |
| Implied change | Forces changes in other areas (e.g. Docker → deployment, networking, config) |
| Dependency | Existing req must be true |
| Unaffected | Skip |

Compile discussion list.

## 6. Interview

Use the `skill` tool to load `grill-with-docs`. Follow its interview methodology (one question at a time, sharpen terms, update glossary inline, offer ADRs sparingly).

**Superseding:** If candidate conflicts with existing req in `requirements.md` → confirm, mark existing `[~]`, add replacement `[ ]`. Keep old text.

## 7. Update files

### 7a. requirements.md

- Preserve sections. Update `[ ]`↔`[x]`↔`[~]` per convention
- New reqs: `- [ ] <desc>` (1-3 sentences) in logical section (or new `##`)
  ⚠️ New reqs = `[ ]` always. `[x]` = consumed by prior pass, not "implemented". Next step scans `[ ]` only.
- Superseded reqs: `[~]` with original text
- Check for contradictions/duplicates. Flag vague ones.
- Scan `triage.md` `## Fixed` for enhancement entries not yet listed in `## Features from Triage`. Append any missing entries (prefixed `[x]`) to keep the triage section up to date.
- Overwrite file.

### 7b. user_requirements.md

Never touch existing `[x]` or `[~]`:

| Item | Action |
|------|--------|
| Already covered | `[x]` |
| Agreed after interview | Update text if clarified, `[x]` |
| Pruned | `[~] <reason>` |

Overwrite file.