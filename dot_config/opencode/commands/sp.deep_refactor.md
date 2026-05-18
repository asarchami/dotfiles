---
description: Explore the codebase, compare against the PRD's deep module design, and propose deepening opportunities using the improve-architecture skill
---

## 1. Load PRD design intent

Read `spec/prd.md`. Extract every **Module sketch & deep module design** subsection and build a reference map of intended module depth:

| Package | PRD classification | Intended interface | Intended implementation |
|---------|-------------------|-------------------|------------------------|
| `internal/exchange/` | Deep | 3-method interface | REST, auth, rate-limit, retry, parsing |
| `internal/lua/` | Deep | register/evaluate API | VM pool, sandboxing, marshaling, timeout |
| `internal/db/` | Potentially deep | connection mgmt, query helpers | hypertables, compression, backoff |
| `internal/symbol/` | Shallow | CRUD Store | straightforward DB access |
| `internal/config/` | Shallow | env-var loading | trivial |
| `cmd/ticker/` | Thin binary | compose deep modules | polling loop orchestration |
| `cmd/trading/` | Thin binary | compose deep modules | read-evaluate-execute loop |
| `cmd/backtest/` | Thin binary | compose deep modules | time-range iteration |
| `cmd/web-ui/` | Thin binary | compose deep modules | template rendering + HTMX |

## 2. Load issues context

Read `spec/issues.md` to understand which slices are implemented (`[x]`) and which are still pending. Only inspect implemented slices — pending slices haven't been built yet so there's nothing to refactor.

## 3. Explore the codebase

Use explore agents to walk the implemented code. For each module from step 1, assess its actual depth. Use the heuristics from the [improve-architecture](../skills/improve-architecture/SKILL.md) skill:

- **Deletion test**: would deleting the module concentrate complexity or just move it?
- **Interface vs implementation**: does the exported API hide internal complexity, or does it leak?
- **One adapter or two?** Does the interface have a mock/adapter for testing? A production-only seam is just indirection.
- **Test surface**: do tests cross the same seam as callers? Or do they need to peer into internals?

## 4. Compare reality against intent

For each module, classify the delta:

| PRD classification | Reality | Action |
|--------------------|---------|--------|
| Deep module | Still deep | No action — confirm and move on |
| Deep module | Went shallow | **Deepening candidate** — present for discussion |
| Shallow module | Still shallow | No action (intentionally shallow) |
| Thin binary | Still thin | No action |
| Thin binary | Accumulated logic | **Candidate**: extract deep module out of the binary |

## 5. Load the skill

Use the `skill` tool to load the `improve-architecture` skill. This injects LANGUAGE.md, INTERFACE-DESIGN.md, and DEEPENING.md into context.

## 6. Present candidates

**Activate caveman mode** (use the `skill` tool to load the `caveman` skill) for the candidate presentation. Each candidate is a structured data point — terse is better. Follow the caveman skill's **Auto-Clarity Exception**: deactivate before asking "which candidates they'd like to explore."

Present a numbered list of deepening opportunities found in step 4. For each candidate:

- **Files** — which files/packages are involved
- **Problem** — why the current architecture is causing friction (in LANGUAGE.md vocabulary: shallow interface, poor locality, seam discipline)
- **PRD intent** — what the PRD originally specified for this module
- **Solution** — plain English description of what would change
- **Benefits** — explained in terms of locality and leverage

Ask the user which candidates they'd like to explore. Deactivate caveman before the question.

## 7. Grilling loop

For the chosen candidate, walk through the design tree:

- Constraints and dependencies (classify per [DEEPENING.md](../skills/improve-architecture/DEEPENING.md))
- Interface alternatives (use [INTERFACE-DESIGN.md](../skills/improve-architecture/INTERFACE-DESIGN.md) for parallel sub-agent design)
- Testing strategy — what tests survive, what tests get replaced
- Impact on existing callers

## 8. Update spec/prd.md (if needed)

After the design is settled, if the deepened module's design **contradicts** the current `spec/prd.md`:

- Ask the user: "This change diverges from `spec/prd.md`'s module sketch — should I update it?"
- Only update if they say yes
- If updating, preserve the existing PRD structure and update only the affected section

## 9. Report

**Reactivate caveman mode** for the summary. Deactivate for the recommendation (user-facing).

Summarize what changed. Recommend running `sp.implement` next if there are pending issues slices, or running `sp.deep_refactor` again after more code accumulates.
