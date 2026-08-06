---
name: handoff
description: "Write a handoff document that compacts this session so a fresh agent can continue the work."
license: MIT
---

# Handoff

**Leading word: handoff.** A relay race is won at the baton pass, not the sprint. **Handoff** means the next agent picks up the work without re-reading this conversation: current state, decisions, next actions, and pointers to the artifacts that already hold the detail.

## Steps

1. **Assemble the context.** Collect the working state: what was built or decided, open threads, pending questions, and every artifact that already captures this work (specs, PRDs, plans, ADRs, issues, commits, diffs).

   *Done when: each artifact relevant to the work is listed with a path or URL.*

2. **Write the compact.** Summarize the current state, key decisions, and the next actions — one screen, readable in minutes. Reference artifacts by path or URL; never restate their content.

   *Done when: nothing in the document duplicates an artifact's content, and the next agent can start without reading the conversation.*

3. **Name the suggested skills.** Add a `Suggested skills` section listing the skills the next agent should invoke. Confirm each name is a real, loadable skill in this environment before suggesting it.

   *Done when: every suggested skill appears in your available skills.*

4. **Redact.** Scan the draft for API keys, passwords, tokens, and personally identifiable information.

   *Done when: no sensitive value survives in the document.*

5. **Save to the temp directory.** Write `<project>-handoff-<YYYY-MM-DD>.md` to the OS temp directory (`$TMPDIR` on Unix/macOS, `%TEMP%` on Windows), not the workspace.

   *Done when: the file exists outside the workspace and its absolute path is reported to the user.*

6. **Tailor to the next session.** If the user's invocation describes what the next session will focus on, shape the next actions and suggested skills around that focus.

   *Done when: the document's next actions match the stated focus.*

## Reference

### Suggested document shape

| Section | Purpose |
| --- | --- |
| Current state | What exists and works now |
| Decisions | Choices made and why |
| Next actions | Ordered steps for the next session |
| Open questions | Things blocking or undecided |
| Suggested skills | Skills the next agent should invoke |
| Artifacts | Paths/URLs to specs, PRDs, ADRs, issues, commits, diffs |

### Temp directory

The OS temp directory — `os.TempDir()` — `$TMPDIR` on Unix/macOS, `%TEMP%` on Windows. A handoff document never belongs in the workspace; it is transient by design.

## Watch for

| Mistake | Fix |
| --- | --- |
| Restating spec/ADR content | Reference it by path or URL |
| Saving into the workspace | Write to the OS temp directory |
| Leaving secrets or PII in the document | Redact before saving |
| Suggesting a skill that doesn't exist | Verify against available skills |
| Producing a full transcript | Compact — a fresh agent reads it in minutes |
