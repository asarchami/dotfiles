---
description: Diff spec/prd.md against spec/issues.md, interview the delta, then update spec/issues.md
---

## 1. Load existing issues

Read `spec/issues.md` if it exists. Extract every `### <number>. <Title>` section as a reference list of *already-documented* slices. For each slice note: title, type (HITL/AFK), blocked-by, user stories covered, description, and acceptance criteria. Store the full document — you'll amend it later.

## 2. Load current PRD

Read `spec/prd.md`. Extract every `### <title>` section and its constituent content — especially user stories, acceptance criteria, dependencies, and out-of-scope items.

From the **Architecture** section and each PRD section's **Module sketch & deep module design** subsection, extract the deep/shallow/thin classification for every package using the guidance in the `to-issues` skill's **Deep Module Design** section. Store this classification — it will guide the slice decomposition.

## 3. Load to-issues skill

Use the `skill` tool to load the `to-issues` skill. This injects the vertical-slice decomposition methodology, deep module design guidance, quiz flow, and publish format into the conversation context.

## 4. Diff against existing issues

Compare the current PRD sections (step 2) against the already-documented slices (step 1). Identify:

- **New sections** — PRD sections that have no corresponding slice in issues.md
- **Changed sections** — PRD sections whose content has meaningfully changed (user stories, acceptance criteria, dependencies, out-of-scope, or architecture decisions that affect the slice breakdown)
- **Already covered** — PRD sections whose content is fully captured by existing slices (skip these)

If there are no new or changed sections at all, confirm to me that the issues doc is up-to-date and exit.

If issues.md does not exist, treat all PRD sections as **new** and proceed to create the initial breakdown.

## 5. Assess impact on existing slices

For each new or changed PRD section from step 4, reason about how it affects the existing or planned slices:

- **Direct conflicts** — the new/changed content contradicts or supersedes an existing slice's scope or acceptance criteria
- **Implied changes** — the new content forces changes in other slices (new dependencies, reordering, merging, splitting)
- **Dependencies** — existing slices whose blocked-by relationships must be updated
- **Unaffected** — skip these; no need to re-interview

Compile a consolidated list of **items to discuss**: which existing slices need updating, which new slices need to be added, and any structural changes (merge/split/reorder).

## 6. Interview (using to-issues quiz flow)

Follow the `to-issues` skill's quiz flow. Interview me about the consolidated list only. Walk down each branch of the decision tree, resolving dependencies one by one.

## 7. Update spec/issues.md (using to-issues publish format)

Once all branches are resolved — no more meaningful questions remain — update `spec/issues.md` using the publish format from the `to-issues` skill:

- Preserve existing `### <number>. <Title>` sections (update fields where decisions changed)
- Add new `### <number>. <Title>` sections for new slices (renumber sequentially)
- For impacted existing slices, update only the fields that changed
- Include metadata: date, source document (`spec/prd.md`), status
- Include the `## Dependency Graph` section with Mermaid flowchart
- Do not add commentary or explanation beyond the structured fields
- Write the result to `spec/issues.md` (overwrite if exists)
