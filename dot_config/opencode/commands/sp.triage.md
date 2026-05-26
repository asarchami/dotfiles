---
description: Report and resolve a bug/feature request, or triage open items from spec/triage.md.
---

If `$ARGUMENTS` is non-empty, go to **Report mode** (create a new entry in `spec/triage.md` and resolve it).
If `$ARGUMENTS` is empty, go to **Triage mode** (show open items from `spec/triage.md` and resolve one).

---

## Report mode — `/sp.triage <description>`

### 1. Classify

Read `$ARGUMENTS` and classify as **bug** or **enhancement**. If ambiguous, ask the user.

### 2. Gather details

Ask the user any missing information needed for the template:

**For bugs:**
- Title
- Severity (critical / high / medium / low)
- Steps to reproduce
- Expected behavior
- Actual behavior

**For enhancements:**
- Title
- Severity (critical / high / medium / low)
- Description

Use today's date for **Reported:**. Default severity to **medium** if unsure.

Write all descriptions and summaries in **caveman style** — drop filler words/articles, keep full technical accuracy, 1 sentence max. Aim for ~70% token reduction vs natural language.

### 3. Read triage.md

Read `spec/triage.md`. Parse all `### <N>. <Title>` entries under both `## Open` and `## Fixed` to determine the next issue number (`max N + 1`).

### 4. Create the entry

Append the new entry at the end of the `## Open` section using this format:

**Bug template:**
```markdown
### <N>. <Title>
bug | <severity> | YYYY-MM-DD | open
<1-line caveman description>

**Steps:**
1. <step 1>
**Expected:** <expected>
**Actual:** <actual>
```

**Enhancement template:**
```markdown
### <N>. <Title>
enhancement | <severity> | YYYY-MM-DD | open
<1-line caveman description>
```

Write the updated file back.

### 5. Resolve the issue

Now resolve the entry you just created:

1. Load the **triage** skill.
2. **For bugs:** load the **diagnose** skill. Reproduce the bug, hypothesise root cause, instrument, fix, and add a regression test.
3. **For enhancements:** scope check. If large/cross-cutting, tell the user to use `sp.requirements` instead. If small and contained, implement the feature.
4. Run `go build ./...` and `go test ./...` to verify.
5. Present the diff and test results to the user.
6. **Wait for user confirmation.** Do NOT mark as fixed without it.
7. On confirmation, move the entry from `## Open` to `## Fixed` in `spec/triage.md`:
   - Change `open` → `fixed` in the metadata line
   - Add `**Fix:** <caveman summary, 1-3 comma-separated items>`
   - Remove verbose sections (**Steps:**, **Expected:**, **Actual:**) if present
   - Keep **Description** line as-is

8. **Sync enhancement to requirements.md.** If the resolved entry's **Type** is `enhancement`:
   - Read `spec/requirements.md`
   - Find or create `## Features from Triage` section (append before EOF if missing)
   - Append: `- [x] #<N>. <Title>` (if not already present)
   - Write back

---

## Triage mode — `/sp.triage` (no arguments)

### 1. Read triage.md

Read `spec/triage.md`. Parse `## Open` and `## Fixed` sections. Extract every `### <N>. <Title>` entry with its type, severity, status, and description.

### 2. Show open items

If there are no open items, report this and exit.

Otherwise, present all `## Open` entries sorted by severity (critical → high → medium → low). Show:

```
Open items:

  1. [bug] [high]  Order submission fails with HTTP 429
  2. [enhancement] [low]  Add rate-limit config option
  3. [bug] [medium] Backtest PnL wrong for shorts

  Which would you like to triage? (number)
```

Wait for the user to pick one.

### 3. Load triage skill

Use the `skill` tool to load the `triage` skill.

### 4. Gather context

Explore the codebase to understand the relevant area. Check `.out-of-scope/*.md` for prior rejections if this is an enhancement.

### 5. Attempt reproduction (bugs only)

Trace through the code path described in the bug report. Run relevant tests. Report:
- **Can reproduce** — describe the code path and observed behavior
- **Cannot reproduce** — flag as `needs-info`, explain what's missing, update the entry's status to `needs-info` in `spec/triage.md`, then exit

### 6. Scope check (enhancements only)

If the enhancement is large or cross-cutting (touches multiple modules, requires new packages, changes data model) — tell the user this should go through `sp.requirements` instead and exit.

If the enhancement is small and contained (adds a config field, tweaks an existing function, adds a minor endpoint) — proceed.

### 7. Load diagnose skill (bugs only)

Use the `skill` tool to load the `diagnose` skill. Follow its workflow:
- Build feedback loop (relevant test)
- Reproduce the failing behavior
- Hypothesise root cause
- Instrument (add logging, more specific assertions)
- Fix + regression test
- Cleanup

### 8. Implement fix

Write the fix. For enhancements, implement the minor feature directly. Run `go build ./...` and `go test ./...` to verify.

### 9. User confirmation

Present the diff and test results to the user:

```
=== Fix ready ===
<diff summary>
<test output>

Can you confirm this resolves the issue? (y/n)
```

**Do NOT mark as fixed without user confirmation.** If user says no, ask what's missing and loop back to step 7 or 8.

### 10. Update spec/triage.md

On user confirmation:

- Move the entry from `## Open` to `## Fixed`
- Change `open` → `fixed` in the metadata line
- Add `**Fix:** <caveman summary, 1-3 comma-separated items>`
- Remove verbose sections (**Steps:**, **Expected:**, **Actual:**) if present
- Keep **Description** line as-is

### 10b. Sync enhancement to requirements.md

If the resolved entry's **Type** is `enhancement`:

1. Read `spec/requirements.md`
2. Find or create `## Features from Triage` section (append before EOF if missing)
3. If an entry `#<N>.` with the same issue number is not already present, append: `- [x] #<N>. <Title>`
4. Write back

### 11. Loop

Ask if the user wants to triage another open item. If yes, go to step 2.
