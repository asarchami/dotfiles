# Engineering ground rules

Cross-project rules, each earned from a real incident. The incident is kept
attached to the rule on purpose: a bare imperative gets rationalized around, a
rule with a corpse next to it does not.

Project-level `CLAUDE.md` files override anything here.

## Scope

- **Do exactly what was asked. Raise adjacent concerns as a question, not as an
  action.** This is the single largest source of friction in practice — a review
  of a month of sessions found 25 rejected actions and 17 wrong-approach flags
  clustered on one shape: a narrow request ("commit") expands into verification
  steps, unrelated edits and clarifying questions until it gets interrupted. The
  same failure happens at large scale too — asked to make a project win on
  *process*, the first proposal was a fourth product feature, corrected in one
  line. Noticing an adjacent improvement is useful; performing it uninvited is
  the thing that gets interrupted. Say it, don't do it.

## Committing

- **Always invoke the `commit-message` skill before writing any commit message.**
  Every commit, every project, no exceptions — including single-file commits,
  amends, and commits made as an incidental step in a larger task. Do not compose
  a message from memory of the convention; the skill is the convention. It is
  vendored from an internal skills repository and mirrors what commitlint
  (`@commitlint/config-conventional`) actually enforces, so a message written
  without it is a message that may fail CI.

- **Commit early and commit often.** Small, focused commits as work lands rather
  than batching. Uncommitted work piling up is how a session's worth of good
  changes becomes unreviewable in one lump, and how a bad change becomes
  impossible to isolate.

## Verification

- **Never read a gate's verdict off the end of a pipe.** `./gate.sh 2>&1 |
  tail -12` puts `tail`'s exit status in `$?`, not the gate's, so a failing check
  reports success and the FAILED line scrolls past above whatever the tail window
  happened to show. This happened twice in one session — the second time while
  writing a skill about verification — and the first instance committed a broken
  build. Redirect to a file and check the status (`./gate.sh > /tmp/g.log;
  echo $?`), or use `PIPESTATUS`. A gate is only a gate if its exit status is the
  thing you actually look at.

- **Never skip the static-analysis step in a build/test gate.** It is not a
  formality alongside compilation. `go vet` caught a real shipped-then-caught bug
  (a 10-verb/9-argument `Sprintf`) that both `go build` and `gofmt` missed. The
  same holds for the equivalent in any language — the type checker, the linter,
  the strict mode. Compilation succeeding is not the same as the code being
  right.

- **Verify a surprising, specific claim about library or standard-library
  behaviour with a minimal standalone repro before accepting it.** When a
  subagent — or you — asserts something like "`html/template` escapes `+` to
  `&#43;`", build the two-line repro. That specific claim turned out to be true,
  but the habit is the point: a wrong claim here either papers over a real bug or
  needlessly weakens a security-relevant test assertion, and both are invisible
  once the test has been "adjusted to match".

- **When a subagent reports "builds, vets, tests all pass," read the actual diff
  before moving on.** Self-reports are not evidence. Two real bugs in one build
  (a `.gitignore` cross-file negation silently doing nothing; a nonexistent scan
  root exiting 0 instead of 1) were caught by writing and reading real tests
  after the fact, not by the implementing agent's own passing report.

- **After wiring an analysis or aggregation feature together, run it against real
  input and sanity-check the headline numbers against what you already know to be
  true.** This caught a bug no unit test surfaced: Go `_test.go` files' `TestXxx`
  functions are capitalized (matching an exported-identifier heuristic) but are
  conventionally never doc-commented, dragging a documentation-coverage metric
  down for reasons unrelated to actual API documentation. Invisible to any
  single-file unit test; obvious in the aggregate across many files.

## Delegation

- **Give a subagent a command as its success signal, not a description of the
  goal.** "Reduce complexity in this package" produces taste; a concrete
  `<tool> --json | jq '<path>'` with a target number produces convergence. Pair
  it with an explicit anti-gaming instruction, because a metric handed to an
  optimizer will be optimized — one agent cleared two duplication findings with
  edits whose main effect was changing the hashed line text.

- **Do integration and wiring points yourself rather than delegating them.**
  Orchestration, CLI flag wiring, UI state updates. Across four phases of one
  build, every escaped bug was in exactly this category. These are the seams
  where independently-correct pieces get connected, and connecting them is where
  assumptions about the other side turn out wrong.
