---
name: skillsmith
description: Forge, retune, and refactor opencode agent skills with one repeatable process.
compatibility: opencode
---

# Skillsmith

A skill exists to wrangle determinism out of a stochastic system — the agent taking the same **process** every run. Skillsmith is the process that forges, retunes, and refactors those skills, tuned to the opencode harness. Its root virtue is **predictability**; every step below serves it.

**Bold terms** are defined in [`GLOSSARY.md`](GLOSSARY.md).

## The smith's shapes

The work takes one of three shapes. Name the shape first; the steps adapt to it.

- **Forge** — a new skill from scratch, or from a fragment of an idea.
- **Retune** — a small, targeted change to an existing skill.
- **Refactor** — an existing skill that misbehaves: won't fire, rushes, sprawls, or drifts.

## Step 1 — Question the smith first

Before any file is written or edited, ask the human what would make the skill *right*. Use the `question` tool, one focused question at a time, and let the answers shape the work. Do not start with the file; start with intent.

Ask, as relevant:

- **What is the skill for?** What behaviour should the agent take predictably? What does done look like?
- **Who fires it?** Model-invoked (a description in the window; the agent can reach it) or user-invoked (typed by name; no trigger to the agent).
- **Where does it live?** Project or global; which **discovery path**.
- **What are its branches?** Each distinct way it can be invoked gets its own trigger.
- **What must it mirror?** Neighbouring skills, category folders, language, tone.

Completion criterion: every answer that could change the skill's shape is captured, and you can state in one sentence each — the skill's purpose, its invocation, and its branches. An unanswered question is a decision for Step 3, not a skip.

## Step 2 — Place and name for the harness

Create the skill at its **discovery path** — one folder per skill, named for the skill. Prefer the project tree for a repo-bound skill, the global tree for a cross-project one.

Name it to opencode's rules: `^[a-z0-9]+(-[a-z0-9]+)*$`, 1–64 chars, matching the folder name. The name is the **leading word** the human types — make it say what the skill does.

Frontmatter carries at least `name` and `description`; the full field rules live in the GLOSSARY. Write the description for the invocation you chose:

- **Model-invoked** — a model-facing trigger: the skill's leading word front-loaded, one trigger per branch, identity already in the body cut. Every word is **context load**; prune harder than the body.
- **User-invoked** — a human-facing one-liner, triggers stripped.

Completion criterion: folder and name satisfy the regex and match each other; frontmatter carries at least `name` and `description`; the description matches the invocation choice and carries the skill's leading word.

## Step 3 — Forge the body

Write the body the way the agent will read it — top-down down the **ladder**: the steps it must run first, the reference it consults, the failures to watch for.

- **Steps** are ordered actions; every step ends on a **completion criterion** that is checkable and, where it matters, exhaustive. A vague bound invites **premature completion**.
- **Reference** sits below the steps — definitions and rules consulted on demand. Inline what every branch needs; push what only some branches reach behind a **context pointer** into a sibling file.
- **Leading words** anchor behaviour: a compact pretrained concept, repeated as a token, that recruits priors so the agent reaches for the same behaviour every run. Reach for an existing word before coining one.
- **Prompt the positive.** State the target behaviour; a prohibition names the elephant and makes it more available.
- **Co-locate.** A concept's definition, rules, and caveats under one heading, not scattered.

A demanding completion criterion drives **legwork** — the digging the agent does within a step. "Every modified skill accounted for" beats "produce a change list".

Completion criterion: every step ends on a criterion that passes the done/not-done test; every branch has exactly one trigger; reference only some branches need sits behind a pointer, not inline.

## Step 4 — Run the pruning discipline

Hunt **no-ops** sentence by sentence — delete the sentence, not words from it — then **duplication** (one meaning, one place: **single source of truth**), then **relevance**: does the line still bear on what the skill does? Be aggressive; most prose that fails goes, not gets rewritten.

## Step 5 — Validate against the harness

Run the harness checklist in the GLOSSARY; fix anything that fails. When a mechanic is uncertain, consult the harness docs with `webfetch`.

Completion criterion: every checklist line passes.

## Step 6 — Verify the fire

A skill is only a skill when it fires. Hand the human the exact trigger — for a user-invoked skill, its name; for a model-invoked one, a prompt carrying its leading word — and confirm the skill appears in the `skill` tool's available list in a fresh session. If it is absent, step through the load-failure checklist in the GLOSSARY.

Completion criterion: a fresh session lists the skill and, on invocation, the agent runs the skill's own first step — proof the process, not just the file, is right.

## Refactor — when a skill misbehaves

Run this when the human reports a skill that won't fire, rushes, sprawls, or drifts. Diagnose with the failure modes, then apply the cure:

- **Won't fire** — the description is the trigger. Sharpen the leading word, keep one trigger per branch, cut duplication; then re-run the harness checklist (name, permissions).
- **Rushes** — **premature completion**: sharpen the completion criterion first (cheap, local); hide the **post-completion steps** only if the bound is irreducibly fuzzy *and* you observe the rush.
- **Sprawls** — push reference down the ladder behind pointers; split by **branch** or sequence.
- **Drifts** — **sediment**: clear stale lines; **duplication**: merge to a single place; re-run the pruning discipline.
- **Ignores a line** — a **no-op** (the model already does it) or a **negation** (a prohibition naming the banned behaviour). Delete the no-op; rephrase the ban as the positive.

A refactor that stays small is a **retune**: one step, one criterion, then re-validate and re-verify.

Completion criterion: the diagnosed failure mode is named; its cure is applied; the skill passes the harness checklist and fires in a fresh session.
