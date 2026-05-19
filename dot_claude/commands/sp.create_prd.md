---
description: Diff spec/requirements.md against spec/prd.md, interview the delta, then update spec/prd.md
---

## 1. Load existing PRD

Read `spec/prd.md` if it exists. Extract every `### <title>` section as a reference list of *already-documented* requirements. For each section, note the 12 dimensions that are filled in and the out-of-scope items. Store the full document — you'll amend it later.

## 2. Load current requirements

Read `spec/requirements.md`. Extract every `## <section>` title and its constituent checkbox requirements (`- [ ]` or `- [x]`).

## 3. Load to-prd skill

Use the `skill` tool to load the `to-prd` skill. This injects the 12-dimension framework, deep module design guidance, and PRD section template into the conversation context.

## 4. Diff against existing PRD

Compare the current requirements (step 2) against the already-documented PRD sections (step 1). Identify:

- **New sections** — requirement sections in requirements.md that have no corresponding `###` section in prd.md
- **Changed sections** — sections that exist in both but whose checkbox requirements differ (new requirements added, old ones removed, or intent changed)
- **Already covered** — sections whose checkbox requirements match the PRD content and need no update (skip these)

If there are no new or changed sections at all, confirm to me that the PRD is up-to-date and exit.

## 5. Assess impact on existing PRD sections

For each new or changed requirement from step 4, reason about which existing PRD `###` sections it affects:

- **Direct conflicts** — the new/changed requirement contradicts or supersedes content in an existing PRD section (e.g. adding Docker means Architecture's "Out of scope: Containerization" is now wrong)
- **Implied changes** — the new/changed requirement logically forces a change in another PRD section's dimensions (user stories, acceptance criteria, edge cases, out of scope, etc.)
- **Dependencies** — existing PRD sections whose acceptance criteria must be true for the new requirement to work
- **Unaffected** — skip these; no need to re-interview

Compile a consolidated list of **items to discuss**: the new/changed sections plus any impacted existing PRD sections with the specific fields that need updating.

## 6. Interview (using to-prd dimensions)

Follow the `to-prd` skill's interview guidance. Interview me about the consolidated list only. Walk down each branch of the decision tree, resolving dependencies between decisions one by one. For each question, provide your recommended answer.

Ask questions **one at a time**. Do not batch questions.

Start with the most foundational / high-impact questions first (new sections, then cross-cutting implied changes) before drilling into specifics.

For each new section, extract and clarify all 12 dimensions from the `to-prd` skill.

For impacted existing sections, interview only about the specific dimensions that need updating — do not re-interview the entire section.

If a question can be answered by exploring the codebase, explore the codebase instead.

## 7. Update spec/prd.md (using to-prd template)

Once all branches are resolved — no more meaningful questions remain — update `spec/prd.md` using the PRD section template from the `to-prd` skill:

- Preserve existing `###` sections and their 12 dimensions (update fields where decisions changed)
- Add new `### <title>` sections for new requirement sections from requirements.md, with all 12 dimensions
- For impacted existing sections, update only the fields that changed (do not rewrite the entire section)
- Update the `## Open Questions` section — remove resolved items, add new unresolved ones
- Update the metadata line: `**Source:** spec/requirements.md` and `**Status:** Draft — all sections discussed, open questions documented`
- Do not add commentary or explanation beyond the structured fields
- Write the result to `spec/prd.md` (overwrite if exists)
