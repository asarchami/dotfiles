# Glossary — Skillsmith

The harness reference for [`skillsmith`](SKILL.md): the opencode mechanics a skill must satisfy, the authoring vocabulary it shares with the reference skill *writing-great-skills*, and each **failure mode** beside its cure. **Bold terms** here are defined in this file. When a mechanic is uncertain, consult the harness docs with `webfetch` (https://opencode.ai/docs/skills/).

## The harness — opencode

### Harness

opencode. A skill only works when it satisfies the harness's mechanics, and the harness is what skillsmith is tuned to. Skills are discovered on-demand via the native `skill` tool: the agent sees each skill's `name` and `description`, and loads the full `SKILL.md` when the skill is invoked.

### Discovery Paths

Where opencode looks for `SKILL.md`. One folder per skill, named for the skill:

- Project: `.opencode/skills/<name>/SKILL.md` (opencode walks up from the working directory to the git worktree root)
- Global: `~/.config/opencode/skills/<name>/SKILL.md`
- Project Claude-compatible: `.claude/skills/<name>/SKILL.md`
- Global Claude-compatible: `~/.claude/skills/<name>/SKILL.md`
- Project agent-compatible: `.agents/skills/<name>/SKILL.md`
- Global agent-compatible: `~/.agents/skills/<name>/SKILL.md`

### Name Rules

`name` must be 1–64 characters, lowercase alphanumeric with single hyphen separators, not start or end with `-`, no consecutive `--`, and match the folder name. Regex: `^[a-z0-9]+(-[a-z0-9]+)*$`. The name is what the human types to fire the skill — word it as the skill's leading word.

### Frontmatter

`SKILL.md` must start with YAML frontmatter. Only these fields are recognized:

- `name` (required)
- `description` (required, 1–1024 characters)
- `license` (optional)
- `compatibility` (optional) — declare the harness, e.g. `opencode`
- `metadata` (optional, string-to-string map) — e.g. `audience`, `workflow`; carried through untouched

Unknown fields are ignored — don't ship them. In particular `disable-model-invocation` is not recognized by opencode: it is kept only for Claude/Agent portability and does nothing here.

### Invocation in the Harness

opencode loads every skill's name and description into the agent's `skill` tool — there is no true user-only state. **User-invoked** is expressed by description *wording*: a human-facing one-liner with no trigger invites nothing, so the agent never fires it unprompted. The hard way to hide a skill entirely is the `permission.skill` config (see Permissions). Treat "user-invoked" as a description-styling decision; the `disable-model-invocation` toggle from other skill systems does not apply.

### Description

Required. Two jobs — state what the skill is, and list the branches that should trigger it. Every word is **context load** for a model-invoked skill, so it earns harder pruning than the body: front-load the leading word, keep one trigger per branch (synonyms that rename one branch are duplication), and cut identity already in the body.

### Permissions

Control which skills an agent can load via `permission.skill` patterns in `opencode.json` or an agent's markdown frontmatter:

- `allow` — skill loads immediately
- `deny` — skill hidden from the agent, access rejected
- `ask` — user prompted for approval before loading

Patterns support wildcards (`internal-*` matches `internal-docs`, `internal-tools`, etc.). The way to make a skill effectively user-only in opencode is `permission.skill: { "<name>": "deny" }` — but that hides it everywhere, not just from the agent, so prefer description wording first.

### Harness Checklist

Run this on every skill, forged, retuned, or refactored:

- [ ] `SKILL.md` spelled in all caps
- [ ] Frontmatter present with at least `name` and `description`
- [ ] `name` passes `^[a-z0-9]+(-[a-z0-9]+)*$` and is 1–64 chars
- [ ] `name` matches its folder name
- [ ] `description` is 1–1024 characters
- [ ] `name` is unique across every discovery path (project and global, opencode and Claude and agent)
- [ ] No `permission.skill` rule denies or ask-blocks the skill's name
- [ ] The description matches the chosen invocation (user-invoked: one-liner, no triggers)

### Load-Failure Checklist

When a skill does not appear in the `skill` tool:

1. `SKILL.md` spelled in all caps
2. Frontmatter includes `name` and `description`
3. `name` unique across all discovery locations
4. No `permission.skill` rule set to `deny` (denied skills are hidden from the agent)
5. The file sits at a recognized discovery path

## The authoring vocabulary

Terms shared with the reference skill *writing-great-skills*; defined here so skillsmith can lean on them without restating them.

### Predictability

The degree to which a skill makes the agent behave the same *way* every run — the same process, not the same output. The root virtue; cost and maintainability are symptoms of it, not rivals.

### Information Hierarchy

A skill's content ranked by how immediately the agent needs it, as a ladder: in-skill **steps** (primary), in-skill **reference** (secondary), and reference behind a **context pointer** (disclosed). Push down what only some branches need; inline what every branch needs.

### Steps

The ordered actions the agent performs — when a skill has them, the primary tier. Every step ends on a **completion criterion**. A skill may be all steps, all reference, or both.

### Reference

Material the agent refers to on demand — definitions, facts, parameters, examples. Prime candidate for **progressive disclosure** behind pointers.

### Completion Criterion

The condition that tells the agent a unit of work is done. Two axes: clarity (can the agent tell done from not-done? resists **premature completion**) and demand (how much work it requires — sets **legwork**). The strongest criteria are both checkable and exhaustive.

### Legwork

The work the agent does within a step — reading files, exploring, digging up what it needs rather than offloading to the user. Raised by a demanding **completion criterion** or a strong **leading word**.

### Progressive Disclosure

Moving reference down the ladder, out of `SKILL.md` behind a pointer, so the top stays legible. Licensed by **branching**: disclose what only some branches need; inline what every path needs.

### Branch

A distinct way a skill can be invoked — different runs taking different paths through it. The cleanest disclosure test: inline what every branch needs, push behind a pointer what only some reach.

### Context Pointer

A reference held in context that names out-of-context material and encodes the condition for reaching it. Its wording, not its target, decides when and how reliably the agent reaches the material.

### Leading Word

A compact concept already in the model's pretraining that the agent thinks with while running the skill (e.g. *ladder*, *legwork*, *smith*). Repeats as a token, never a sentence, accumulating a distributed definition that recruits priors. Anchors execution in the body and invocation in the description.

### Post-Completion Steps

The steps that follow the current step. Visible, they pull the agent forward into **premature completion**; the defence is hiding them by splitting the sequence across a context boundary.

### Context Load

The cost a model-invoked skill imposes on the agent's context window — its description, always loaded, spending tokens and attention. The brake on splitting into more model-invoked skills.

### Cognitive Load

The cost of a user-invoked skill — what the human must hold in their head: which skills exist and when to reach for each. Not a cost to minimise; it is the price of human agency.

### Single Source of Truth

The desired state where each meaning lives in exactly one authoritative place, so a behaviour change is a one-place edit. **Duplication** is its violation.

### Router Skill

A user-invoked skill whose job is to point at other user-invoked skills — naming each and when to reach for it — so the human remembers one skill instead of many.

## Failure modes

### Premature Completion

Ending a step before it is genuinely done, attention slipping to *being done*. A between-steps failure. Two levers, in order: sharpen the completion criterion first (cheap, local); only if it is irreducibly fuzzy *and* you observe the rush, hide the post-completion steps by splitting.

### Duplication

The same meaning in more than one place. Costs maintenance and tokens; inflates a meaning's prominence on the ladder past its real rank. The accidental inverse of a **leading word**, which repeats a token on purpose.

### Sediment

Stale layers that settle because adding feels safe and removing feels risky. The default fate of any skill without a pruning discipline.

### Sprawl

A skill simply too long, even when every line is live and unique. The cure is the **information hierarchy**: disclose reference behind pointers, split by branch or sequence.

### No-Op

A line that changes nothing because the model already does it by default — you pay load to say nothing. The test: does it change behaviour versus the default? A weak leading word (*be thorough* when the agent is already thorough-ish) is a no-op; the fix is a stronger word, not a different technique.

### Negation

Steering by prohibition, which drags the banned behaviour into context and makes it more available. Prompt the positive — state the target so the banned one is never spoken; keep a prohibition only as a hard guardrail, and pair it with what to do instead.
