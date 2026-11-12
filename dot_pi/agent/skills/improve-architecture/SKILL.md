---
name: improve-architecture
description: Find deepening opportunities in a codebase using the deep-module vocabulary from the project's PRD. Use when the user wants to improve architecture, find refactoring opportunities, consolidate shallow modules, or make the codebase more testable.
---

# Improve Codebase Architecture

Surface architectural friction and propose **deepening opportunities** — refactors that turn shallow modules into deep ones. The aim is testability and maintainability.

## Glossary

Use these terms exactly in every suggestion. Consistent language is the point. Full definitions in [LANGUAGE.md](LANGUAGE.md).

- **Module** — anything with an interface and an implementation (function, struct, package).
- **Interface** — everything a caller must know to use the module: types, invariants, error modes, ordering, config. Not just the type signature.
- **Implementation** — the code inside.
- **Depth** — leverage at the interface: a lot of behaviour behind a small interface. **Deep** = high leverage. **Shallow** = interface nearly as complex as the implementation.
- **Seam** — where an interface lives; a place behaviour can be altered without editing in place.
- **Adapter** — a concrete thing satisfying an interface at a seam.
- **Leverage** — what callers get from depth.
- **Locality** — what maintainers get from depth: change, bugs, knowledge concentrated in one place.

Key principles (see [LANGUAGE.md](LANGUAGE.md) for the full list):

- **Deletion test**: imagine deleting the module. If complexity vanishes, it was a pass-through. If complexity reappears across N callers, it was earning its keep.
- **The interface is the test surface.**
- **One adapter = hypothetical seam. Two adapters = real seam.**

This skill is _informed_ by the project's PRD. The PRD's **Module sketch & deep module design** sections document the intended depth of each package — compare actual code against that intent.

## Process

### 1. Explore

Read the relevant **Module sketch & deep module design** sections from `spec/prd.md` to understand the intended depth of each package.

Then use explore agents to walk the codebase. Note where you experience friction:

- Where does understanding one concept require bouncing between many packages?
- Where are modules **shallow** — interface nearly as complex as the implementation?
- Where have pure functions been extracted just for testability, but the real bugs hide in how they're called (no **locality**)?
- Where do tightly-coupled packages leak across their seams?
- Which parts of the codebase are untested, or hard to test through their current interface?

Apply the **deletion test** to anything you suspect is shallow: would deleting it concentrate complexity, or just move it? A "yes, concentrates" is the signal you want.

### 2. Compare against original design

Compare what you found against `spec/prd.md`'s deep module classifications:

| PRD classification | Reality | Action |
|--------------------|---------|--------|
| Deep module | Still deep | No action needed |
| Deep module | Went shallow | Recommend deepening to match original intent |
| Shallow module | Still shallow | No action (intentionally shallow) |
| Shallow module | Evolved into something deeper | Consider updating PRD |

### 3. Present candidates

Present a numbered list of deepening opportunities. For each candidate:

- **Files** — which files/packages are involved
- **Problem** — why the current architecture is causing friction
- **Solution** — plain English description of what would change
- **Benefits** — explained in terms of locality and leverage, and also in how tests would improve

Use [LANGUAGE.md](LANGUAGE.md) vocabulary. If the PRD documents an intended deep module that went shallow, reference it explicitly.

Do NOT propose interfaces yet. Ask the user: "Which of these would you like to explore?"

### 4. Grilling loop

Once the user picks a candidate, drop into a grilling conversation. Walk the design tree with them — constraints, dependencies, the shape of the deepened module, what sits behind the seam, what tests survive.

If the chosen candidate's interface needs design work, use [INTERFACE-DESIGN.md](INTERFACE-DESIGN.md) to generate alternatives via parallel sub-agents.

Use [DEEPENING.md](DEEPENING.md) to classify the candidate's dependencies and determine the right testing strategy.

### 5. Follow-up

After the design is settled:

- If the deepened module's design contradicts the PRD's module sketch, **ask the user**: "This change diverges from `spec/prd.md` — should I update it?" Only update if they say yes.
- If the deepened module affects future slices in `spec/issues.md`, flag it as a heads-up but do not change issues.md automatically.
