---
description: Triage bugs and feature requests from spec/triage.md, reproduce, fix, and confirm resolution.
---

## 1. Load bugs document

Read `spec/triage.md`. Parse `## Open` and `## Fixed` sections. Extract every `### <N>. <Title>` entry with its type, severity, status, and description.

## 2. Show open items

Present all `## Open` entries sorted by severity (critical → high → medium → low). Show:

```
Open items:

  1. [bug] [high]  Order submission fails with HTTP 429
  2. [enhancement] [low]  Add rate-limit config option
  3. [bug] [medium] Backtest PnL wrong for shorts

  Which would you like to triage? (number)
```

Wait for the user to pick one.

## 3. Load triage skill

Use the `skill` tool to load the `triage` skill.

### 3a. Gather context

Explore the codebase to understand the relevant area. Check `.out-of-scope/*.md` for prior rejections if this is an enhancement.

### 3b. Attempt reproduction (bugs only)

Trace through the code path described in the bug report. Run relevant tests. Report:
- **Can reproduce** — describe the code path and observed behavior
- **Cannot reproduce** — flag as `needs-info`, explain what's missing, update the entry's status to `needs-info` in `spec/triage.md`, then exit

### 3c. Scope check (enhancements only)

If the enhancement is large or cross-cutting (touches multiple modules, requires new packages, changes data model) — tell the user this should go through `sp.requirements` instead and exit.

If the enhancement is small and contained (adds a config field, tweaks an existing function, adds a minor endpoint) — proceed.

## 4. Load diagnose skill (bugs only)

Use the `skill` tool to load the `diagnose` skill. Follow its workflow:
- Build feedback loop (relevant test)
- Reproduce the failing behavior
- Hypothesise root cause
- Instrument (add logging, more specific assertions)
- Fix + regression test
- Cleanup

## 5. Implement fix

Write the fix. For enhancements, implement the minor feature directly. Run `go build ./...` and `go test ./...` to verify.

## 6. User confirmation

Present the diff and test results to the user:

```
=== Fix ready ===
<diff summary>
<test output>

Can you confirm this resolves the issue? (y/n)
```

**Do NOT mark as fixed without user confirmation.** If user says no, ask what's missing and loop back to step 4 or 5.

## 7. Update spec/bugs.md

On user confirmation:

- Move the entry from `## Open` to `## Fixed`
- Update status to `fixed` and add `Fixed on: <date>`
- Add a `**Remedy:**` section with 1-3 bullet points describing the fix
- Preserve all original fields (type, severity, reported, description)
- Write the updated file back

## 8. Loop

Ask if the user wants to triage another open item. If yes, go to step 2.
