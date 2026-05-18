---
description: Pick the next unblocked slice from spec/issues.md, plan it, implement it via TDD, and update the issues doc
---

## 1. Read issues document

Read `spec/issues.md`. Parse every `### <number>. <Title>` section. For each slice, extract:
- Number and title
- Type (HITL / AFK)
- Blocked-by list
- User stories covered
- Acceptance criteria checkboxes (`- [ ]` = not done, `- [x]` = done)

## 2. Find next eligible slice

Find the first slice (lowest number) that satisfies **both** conditions:

- Has at least one unchecked acceptance criteria (`- [ ]` present)
- All slices in its **Blocked by:** list have **zero** unchecked acceptance criteria (all `- [x]` in those earlier slices)

If no eligible slice exists:
- Report which slices are still blocked and by what
- Report which slices have unchecked ACs but are unblocked
- Suggest updating `spec/issues.md` if the dependency graph has changed

If all slices have all ACs checked, confirm the project is complete and exit.

## 3. Present the slice

```
Next slice available:

  **3. Exchange interface + mock**

  Type: AFK  |  Blocked by: 1  |  Status: Not started

  User stories: ...

  Acceptance criteria:
  - [ ] Exchange interface with Bars, SubmitOrder, Account methods
  - [ ] ...

  Shall I implement this slice?
```

Wait for confirmation. If HITL, explain human input is needed during planning.

## 4. Load the TDD skill

Use the `skill` tool to load the `tdd` skill. This injects the full TDD workflow and its supporting references (tests.md, mocking.md, interface-design.md, deep-modules.md, refactoring.md) into the conversation context.

## 5. Planning

Use the slice's title, user stories, and acceptance criteria as the scope:

- Read the relevant section from `spec/prd.md` (via **User stories covered**) for module sketch, edge cases, non-functional requirements
- Read `spec/glossary.md` for canonical domain terms — use them in test names and identifiers
- Each `- [ ]` acceptance criteria maps to one or more test targets — these define what to test
- Consider [deep-modules.md](../skills/tdd/deep-modules.md) — does this slice involve a deep module? If so, design the narrow interface before the implementation
- Consider [interface-design.md](../skills/tdd/interface-design.md) — constructor injection, small interfaces, accept interfaces return structs

**Slice type:**
- **HITL**: Ask one question at a time for interface design, test priorities, ambiguities
- **AFK**: Proceed without interrupting — confirm plan with a brief summary

After planning, activate caveman mode for the mechanical implementation steps (use the `skill` tool to load the `caveman` skill). Deactivate temporarily for questions, warnings, or confirmations.

## 6. Tracer bullet + Incremental loop

Write **one test at a time** following the conventions in [tests.md](../skills/tdd/tests.md):

- Table-driven tests with `t.Run` subtests
- `testify/assert` for non-fatal checks, `testify/require` for fatal
- `//go:build integration` tag for integration tests
- Tests use exported API only
- Write minimal code to pass each new test before writing the next test

For each acceptance criteria checkbox, write enough tests to confirm the behavior, then mark it `- [x]` in `spec/issues.md`.

### Unexpected RED — Load diagnose

During the TDD loop, two kinds of RED happen:

| RED type | What it means | Handle with |
|----------|---------------|-------------|
| **Expected** | Test fails because code doesn't exist yet | Normal TDD — write minimal code to pass |
| **Unexpected** | Test reveals bug, regression, or broken behavior in existing code | Load the **diagnose** skill |

**When to load diagnose:** test fails outside the current slice's scope, fails despite correct-looking implementation, existing test breaks unexpectedly, or failure is mysterious/intermittent.

**Procedure:**
1. Pause the TDD loop
2. Use the `skill` tool to load the `diagnose` skill
3. Follow its 6-phase workflow
4. Once fixed and regression test passes, resume the TDD loop
5. If the fix changes the current slice's scope, revisit planning

## 7. Refactor with depth check

After all tests pass for the slice, run a **local depth check** on the module(s) you just implemented:

- **Deletion test**: if you deleted this module, would complexity move to callers or vanish? If callers absorb it, the module is deep enough. If complexity vanishes, it was a pass-through — consider inlining or deepening
- Is the **interface as narrow as the PRD intended**? Compare against the relevant **Module sketch & deep module design** section in `spec/prd.md`. If the PRD says "deep module" but the implementation leaks internals, shrink the exported surface
- Look for [refactoring opportunities](../skills/tdd/refactoring.md): extract duplication, deepen modules, apply Go idioms

If the depth check reveals a module went significantly shallower than the PRD intended, flag it and ask the user whether to deepen it now or defer to `sp.deep_refactor`.

Run `go test ./...` after each refactor step.

## 8. Update spec/issues.md

After implementing all acceptance criteria for the current slice:

- Mark every `- [ ]` for the slice as `- [x]` (or verify already done)
- Do not change any other slice's content
- Write the result back to `spec/issues.md` (overwrite the full file)

## 9. Report next step

Print a summary of what was implemented. Then re-run step 2 to find the next eligible slice:

```
Slice 3 complete. Next eligible: 4. Alpaca implementation (AFK)
```
