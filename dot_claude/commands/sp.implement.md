---
description: Pick the next unblocked slice from spec/issues.md, plan it, implement it via TDD, update the issues doc, and write a manual testing entry
---

## 0. Detect project language

Probe for language config files at the project root to determine which language(s) the project uses:

| Config file | Language | Companion skills |
|---|---|---|
| `go.mod` | Go | `go-testing`, `go-code-style`, `go-error-handling`, `go-lint` |
| `package.json` | JavaScript | *(future: js-testing, js-code-style)* |
| `pyproject.toml` / `requirements.txt` / `setup.py` | Python | `python-testing`, `python-code-quality`, `python-tighten-types`, `python-error-handling` |

**Procedure:**
1. Check for each config file in the project root, in order of the table above
2. If multiple are found (monorepo), report all and ask the user which to use
3. If none found, ask the user what language this project uses
4. Determine the test command, format command, and build command for the detected language

**HTMX detection (after language detection):**
Probe for HTMX usage to determine whether to load HTMX companion skills:

| Probe | How |
|---|---|
| `templates/` or `views/` directory | Check if either directory exists at project root |
| `package.json` with `htmx` | Grep for `"htmx"` in `package.json` |
| `.html` files with `hx-` attributes | Grep for `hx-` in any `.html` files |

If any probe matches, set `htmx_detected = true`. Present to the user: "HTMX detected — will load htmx-spa-conventions companion skill."

**Frontend detection (after HTMX detection):**
Probe for frontend code to determine whether to load web design companion skills:

| Probe | How |
|---|---|
| `templates/`, `views/`, `static/`, or `assets/` directory | Check if any exist at project root |
| `.html` or `.css` files | Check if any exist in the project |
| `package.json` with frontend deps | Grep for `"tailwindcss"`, `"postcss"`, or `"alpinejs"` in `package.json` |

If any probe matches, set `frontend_detected = true`. If `htmx_detected` is also true, will load design skills alongside HTMX skills. If only `frontend_detected` is true, will load design skills only.

**Language-specific mappings (built-in):**

| Language | Test | Build | Format | Lint |
|---|---|---|---|---|
| Go | `go test ./...` | `go build ./...` | `gofmt -s -d .` | `go vet ./...` |
| JS | `npm test` or `npx jest` | `npm run build` | `npx prettier --check .` | `npx eslint .` |
| Python | `pytest` or `python -m pytest` | *(interpreted)* | `ruff format --check` | `ruff check` |

Present the detected language and ask the user to confirm before proceeding. Log which companion skills are available for that language.

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

## 4. Load the TDD skill + language companions

Use the `skill` tool to load the `tdd` skill. This injects the core TDD workflow (red-green-refactor philosophy, tracer bullets, incremental loop) into the conversation context.

Then load companion skills for the detected language from step 0:

| Language | Load these skills |
|---|---|---|
| Go | `go-testing`, `go-code-style`, `go-error-handling`, `go-lint` |
| JS | *(future)* |
| Python | `python-testing`, `python-code-quality`, `python-tighten-types`, `python-error-handling` |

If HTMX was detected in step 0, also load:

| Detected framework | Load these skills |
|---|---|
| HTMX | `htmx-spa-conventions`, `frontend-design`, `interface-design` |

If only `frontend_detected` is true (no HTMX), load:

| Detected framework | Load these skills |
|---|---|
| Frontend | `frontend-design`, `interface-design` |

Example for Go + HTMX:
```
skill tool → load tdd
skill tool → load go-testing      (test conventions, table-driven tests, testify patterns)
skill tool → load go-code-style   (formatting, variable decls, control flow, naming)
skill tool → load go-error-handling  (wrapping, sentinels, slog, single handling rule)
skill tool → load go-lint         (golangci-lint config, nolint directives)
skill tool → load htmx-spa-conventions  (HTMX production patterns, rules, and reference files)
skill tool → load frontend-design      (visual design direction, typography, color, motion)
skill tool → load interface-design     (deep interface craft for dashboards and tools)
```

Example for Python + HTMX:
```
skill tool → load tdd
skill tool → load python-testing      (pytest patterns, fixtures, parametrization)
skill tool → load python-code-quality (ruff, mypy, Pythonic idioms, anti-patterns)
skill tool → load python-tighten-types (type annotation tightening)
skill tool → load python-error-handling (exception patterns, logging)
skill tool → load htmx-spa-conventions  (HTMX production patterns, rules, and reference files)
skill tool → load frontend-design      (visual design direction, typography, color, motion)
skill tool → load interface-design     (deep interface craft for dashboards and tools)
```

The companion skills inject their own references and conventions. The TDD loop uses language-specific patterns from these skills rather than hardcoded Go idioms. If companion skills don't exist for the detected language yet, use sensible defaults (standard test framework, common conventions).

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

Write **one test at a time** following the conventions from the loaded testing companion skill (e.g. `go-testing`). If no companion skill was loaded, fall back to the standard testing conventions for the detected language:

- Use the idiomatic test framework for the language
- Tests use exported/public API only
- Use standard or widely-adopted assertion libraries
- Separate unit and integration tests via the language's standard mechanism (build tags, file suffixes, test markers)
- Write minimal code to pass each new test before writing the next test

Run the test command from step 0 after each change:
- Go: `go test ./...`
- JS: `npm test`
- Python: `pytest`
- Use `-race` / parallel flags where applicable

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
- Look for [refactoring opportunities](../skills/tdd/refactoring.md): extract duplication, deepen modules, apply language-idiomatic patterns

If the depth check reveals a module went significantly shallower than the PRD intended, flag it and ask the user whether to deepen it now or defer to `sp.deep_refactor`.

Run the test command from step 0 after each refactor step. Run the format and lint commands before finalizing.

## 8. Update spec/issues.md

After implementing all acceptance criteria for the current slice:

- Mark every `- [ ]` for the slice as `- [x]` (or verify already done)
- Do not change any other slice's content
- Write the result back to `spec/issues.md` (overwrite the full file)

## 9. Update spec/manual_testing.md

After marking all ACs done in `spec/issues.md`, generate a manual testing section for the implemented slice:

1. Read `spec/manual_testing.md` to understand the existing format
2. Read the slice's **title**, **user stories**, **what to build**, and **acceptance criteria** from `spec/issues.md`
3. Compose a `## Slice N: Title` section following the established pattern:
   - **What it proves:** — one-liner derived from the slice's user stories
   - One subsection per logical test area (unit tests, integration tests, compile-time checks, manual verification steps)
   - Each subsection has a language-appropriate bash command block and an "Expect:" line describing the outcome
   - All test commands must be scoped to the slice's packages (not `./...`)
4. **Run every command** in the proposed section to verify it passes before writing
5. If a command fails, fix the issue or adjust the command until it works
6. Append the new section to `spec/manual_testing.md` just before the final `---`

**Template (Go):**

~~~markdown
## Slice N: Title

**What it proves:** <from user stories>

### Na. Unit tests

\`\`\`bash
go test -v ./internal/<pkg>/ -run <test-pattern>
\`\`\`

Expect: <count> tests pass — <what they verify>.

### Nb. Integration tests

If the slice has an integration test:

\`\`\`bash
docker compose up -d
go test -tags=integration -v ./internal/<pkg>/
docker compose down
\`\`\`

Expect: <count> tests pass.
~~~

For non-Go languages, adapt the commands and test patterns accordingly.

## 10. Report next step

Print a summary of what was implemented. Then re-run step 2 to find the next eligible slice:

```
Slice 3 complete. Next eligible: 4. Alpaca implementation (AFK)
```
