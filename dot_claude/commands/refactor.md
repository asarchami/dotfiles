---
description: Refactor a path against language best-practice skills, using per-package subagents in an isolated worktree
argument-hint: [language] [path]
---

## 0. Parse arguments

`$ARGUMENTS` is `[language] [path]`, both optional.

- If the first whitespace-separated token case-insensitively matches `go`/`golang` or `python`/`py`, that's the `language` and the rest (trimmed) is the `path`.
- Otherwise the whole string is the `path` and `language` is unset.
- If `$ARGUMENTS` is empty, `path` defaults to the repo root and `language` is unset.

Resolve `path` to an absolute path.

## 1. Detect language and component

If `language` is unset, probe under `path` for markers: `go.mod` → go; `pyproject.toml`/`setup.py`/`requirements.txt` → python.

This repo may be a monorepo with multiple components in different languages. If `path` itself has no marker but subdirectories do, or markers for both languages are found under `path`, use `AskUserQuestion` to ask which component/language to target — list the detected candidate directories. Do not guess.

## 2. Discover packages/modules under the target path

Using Bash/Glob directly (not a subagent):

- Go: `find <path> -name '*.go' -not -path '*/vendor/*' -not -path '*/testdata/*' | xargs -n1 dirname | sort -u`, then list the `.go` files in each resulting directory.
- Python: same idea for `*.py`, excluding `venv/`, `.venv/`, `__pycache__/`, `build/`, `dist/`, `site-packages/`.

Build a `packages` array of `{dir, files}`. If it's empty, report that no packages were found under `path` and stop.

## 3. Enter an isolated worktree

Call `EnterWorktree` to create a fresh worktree + branch for this run. All work in the following steps happens inside it — nothing touches the user's current branch. Tell the user the worktree path/branch before continuing.

## 4. Run the refactor Workflow

Call `Workflow` with this inline script, passing `args: {language, rootPath: path, packages}`:

```js
export const meta = {
  name: 'refactor',
  description: 'Refactor packages against language best-practice skills',
  phases: [{ title: 'Refactor' }, { title: 'Verify' }],
}

const PKG_RESULT_SCHEMA = {
  type: 'object',
  properties: {
    dir: { type: 'string' },
    changed: { type: 'boolean' },
    summary: { type: 'string' },
  },
  required: ['dir', 'changed', 'summary'],
}

const VERIFY_SCHEMA = {
  type: 'object',
  properties: {
    passed: { type: 'boolean' },
    details: { type: 'string' },
  },
  required: ['passed', 'details'],
}

const results = await pipeline(
  args.packages,
  pkg => agent(
    `Refactor the ${args.language} package at ${pkg.dir} (files: ${pkg.files.join(', ')}) ` +
    `to align with ${args.language} best practices. Use the Skill tool to load whichever ` +
    `${args.language}-* skills are relevant to what you find in this package (style, error ` +
    `handling, safety/types, testing, docs, performance, concurrency, etc., as applicable — ` +
    `skip skills for libraries/patterns not present in this package). Make the code idiomatic ` +
    `per those skills WITHOUT changing external behavior. Do not touch files outside this ` +
    `package. Return whether anything changed and a short summary.`,
    { phase: 'Refactor', label: `refactor:${pkg.dir}`, schema: PKG_RESULT_SCHEMA }
  )
)

const changed = results.filter(Boolean).filter(r => r.changed)
log(`${changed.length}/${results.length} packages changed`)

const verify = await agent(
  `Run the project's build and lint (and fast unit tests if available) for ${args.language} ` +
  `under ${args.rootPath}. Report pass/fail and any errors verbatim.`,
  { phase: 'Verify', schema: VERIFY_SCHEMA }
)

return { changed, verify }
```

## 5. Leave the worktree in place

Call `ExitWorktree({action: "keep"})`. Do not merge or push anything — that's the user's call.

## 6. Report

Summarize: worktree path and branch, how many packages changed and a one-line reason per changed package, and the verify result (pass/fail + errors verbatim if failed). Tell the user to review the diff in the worktree and merge it themselves when ready.
