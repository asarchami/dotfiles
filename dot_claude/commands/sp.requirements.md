---
description: Interview the user about spec/user_requirements.md to produce a thorough spec/requirements.md
---

## 1. Load existing spec

Read `spec/requirements.md` if it exists. Extract every checkbox requirement (`- [ ]` or `- [x]`) into a reference list of *already-specified* requirements. Store the full document — you'll amend it later rather than rewriting from scratch.

## 2. Load user requirements

Read `spec/user_requirements.md`. Parse the raw notes and extract every distinct requirement statement, normalizing bullets/paragraphs/lists into flat statements.

## 3. Load existing glossary

Read `spec/glossary.md` if it exists. Extract every **<Term>** definition into a reference of *already-defined* domain terms. Note their definitions and flagged ambiguities. Store the full document — you'll amend it as terms are resolved during the interview.

## 4. Diff against existing spec

Compare the user requirements (step 2) against the already-specified requirements (step 1). Identify:

- **New** — topics or statements in user_requirements.md that have no corresponding checkbox in the existing spec
- **Changed** — topics whose intent, nuance, or constraint differs between the two
- **Already covered** — topics fully represented in the existing spec (skip these)

If there are no new or changed items at all, confirm to me that the spec is up-to-date and exit.

## 5. Assess impact on existing requirements

For each new or changed item, reason about which existing requirements it affects:

- **Direct conflicts** — the new item contradicts or supersedes an existing requirement
- **Implied changes** — the new item logically forces a change in another requirement (e.g. adding Docker means deployment, networking, and config requirements may need updating)
- **Dependencies** — existing requirements that must be true for the new item to work
- **Unaffected** — skip these; no need to re-interview

Compile a consolidated list of **items to discuss**: the new/changed items plus any impacted existing requirements.

## 6. Interview + sharpen terminology

Interview me about the consolidated list only. Walk down each branch of the decision tree, resolving dependencies between decisions one by one. For each question, provide your recommended answer.

Ask questions **one at a time**. Do not batch questions.

Start with the most foundational / high-impact questions first (architecture, data model, service boundaries) before drilling into specifics.

If a question can be answered by exploring the codebase, explore the codebase instead.

### Sharpen fuzzy language

During the interview, watch for vague or overloaded terms. When you spot one:

- Cross-reference against existing terms in `spec/glossary.md` (loaded in step 3). If a term conflicts with an existing definition, call it out immediately.
- If no glossary exists yet, propose a precise canonical term when the user uses a vague one.
- Stress-test domain relationships with concrete scenarios that probe edge cases.
- When a term is resolved, **update `spec/glossary.md` inline** — do not batch. Create the file lazily if it doesn't exist. Use the format from the grill-with-docs skill's [CONTEXT-FORMAT.md](../skills/grill-with-docs/CONTEXT-FORMAT.md).

### Offer ADRs sparingly

When an architectural decision is made during the interview that is (a) hard to reverse, (b) surprising without context, and (c) the result of a real trade-off, offer to record it as an ADR in `spec/adr/`. Use the format from [ADR-FORMAT.md](../skills/grill-with-docs/ADR-FORMAT.md).

Do not offer ADRs for decisions that are easy to reverse, obvious, or had no real alternative.

## 7. Update spec/requirements.md

Once all branches are resolved — no more meaningful questions remain — update `spec/requirements.md`:

- Preserve existing sections and checkbox items (update `[ ]` ↔ `[x]` as appropriate)
- Add new requirements in their logical section, or create new `##` sections if needed
- Each requirement is a checkbox item: `- [ ] <description>`
- `[ ]` means not yet implemented. `[x]` means implemented.
- Each requirement is 1-3 short sentences
- Start with `# Requirements` and a brief header explaining the checkbox convention
- Do not add commentary or explanation beyond the requirements
- Include every distinct requirement that was agreed upon — do not merge or drop
- Check for contradictions and duplicates before writing; ask me to resolve any you find
- Flag any remaining vague requirements and ask me to clarify before finalizing
- Write the result to `spec/requirements.md` (overwrite if exists)
