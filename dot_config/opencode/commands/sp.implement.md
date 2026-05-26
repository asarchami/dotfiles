---
description: Pick next unblocked slice from spec/issues.md, implement via TDD, update docs
---

## 0. Detect language + frameworks

Probe root for config files. Load companion skills.

| Config | Lang | Skills |
|--------|------|--------|
| `go.mod` | Go | `go-testing`, `go-code-style`, `go-error-handling`, `go-lint` |
| `package.json` | JS | *(future)* |
| `pyproject.toml`/`requirements.txt`/`setup.py` | Python | `python-testing`, `python-code-quality`, `python-tighten-types`, `python-error-handling` |

1. Check each, order above. Multiple → ask. None → ask.
2. Determine test/format/build:

| Lang | Test | Build | Format | Lint |
|------|------|-------|--------|------|
| Go | `go test ./...` | `go build ./...` | `gofmt -s -d .` | `go vet ./...` |
| JS | `npm test`/`npx jest` | `npm run build` | `npx prettier --check .` | `npx eslint .` |
| Python | `pytest`/`python -m pytest` | *(interpreted)* | `ruff format --check` | `ruff check` |

**HTMX:** `templates/`/`views/` dir, `"htmx"` in `package.json`, or `hx-` in `.html` → `htmx-spa-conventions` + `frontend-design` + `interface-design`.

**Frontend:** `templates/`/`views/`/`static/`/`assets/` dir, `.html`/`.css` files, or `"tailwindcss"`/`"postcss"`/`"alpinejs"` in `package.json` → design skills (alongside HTMX if detected, alone otherwise).

Confirm lang with user.

## 1. Read issues

Read `spec/issues.md`. Parse each `### <N>. <Title>`. Extract: number, title, type, blocked-by, ACs. Convention: `[ ]`=pending, `[x]`=done, `[~]`=superseded.

## 2. Find next eligible slice

First slice (lowest N) where:
- At least one AC is `[ ]` (not `[x]` or `[~]`)
- All Blocked-by slices have zero `[ ]` ACs

`[~]` treated as resolved — doesn't block, doesn't need impl.

None eligible → report state, suggest update. All `[x]`/`[~]` → confirm complete, exit.

## 3. Present slice

```
Next: <N>. <Title> (Type, Blocked by, Status)
ACs:
- [ ] ...
Implement?
```

Wait confirm. HITL → note human input needed.

## 4. Load skills

`skill` → `tdd`. Then per lang + HTMX/frontend detection from step 0.

| Lang | Skills |
|------|--------|
| Go | `go-testing`, `go-code-style`, `go-error-handling`, `go-lint` |
| Python | `python-testing`, `python-code-quality`, `python-tighten-types`, `python-error-handling` |

| Framework | Skills |
|-----------|--------|
| HTMX | `htmx-spa-conventions`, `frontend-design`, `interface-design` |
| Frontend only | `frontend-design`, `interface-design` |

Fall back to sensible defaults if lang has no companion skills.

## 5. Planning

Read `spec/prd.md` (user stories), `spec/glossary.md` (domain terms). Each `[ ]` AC → test targets. Consider deep-modules.md, interface-design.md.

HITL: one question at a time. AFK: proceed, brief summary confirmation.

After plan, load `caveman` for mechanical steps. Deactivate for questions/warnings.

## 6. TDD loop (red-green-refactor)

One test at a time per loaded skill conventions. Test cmd from step 0 after each change.

Mark `[ ]` → `[x]` in `spec/issues.md` as ACs pass. `[~]` unchanged.

**Unexpected RED:** pause, load `diagnose`, 6-phase fix, resume.

## 7. Refactor + depth check

Deletion test, interface narrowness per PRD, refactoring.md patterns.

Run test/format/lint cmds from step 0.

## 8. Update spec/issues.md

All `[ ]` → `[x]` for current slice. Keep `[~]`. Overwrite.

## 9. Update spec/manual_testing.md

Read slice title, stories, ACs, type. Compose per template:

| Type | Subsections |
|------|-------------|
| AFK | Unit tests, Integration (if applicable), Build/compile |
| HITL | Unit tests, Build check, Browser verification, Error handling |

**AC-driven extras:** keyword match table (docker compose, Dockerfile, .env.example, port health, HTTP reachability).

Run every command to verify. Fix if needed.

## 10. Report + loop

```
Slice <N> complete. Next eligible: <M>. <Title> (<Type>)
```

Re-run step 2.
