---
name: diagnose
description: Disciplined diagnosis loop for hard bugs and performance regressions. Reproduce → minimise → hypothesise → instrument → fix → regression-test. Use when user says "diagnose this" / "debug this", reports a bug, says something is broken, or describes a performance regression.
---

# Diagnose

A discipline for hard bugs. Skip phases only when explicitly justified.

When exploring the codebase, use the project's domain vocabulary from `spec/prd.md` and review the relevant slice in `spec/issues.md` to understand the affected module boundaries.

## Phase 1 — Build a feedback loop

**This is the skill.** Everything else is mechanical. If you have a fast, deterministic, agent-runnable pass/fail signal for the bug, you will find the cause — bisection, hypothesis-testing, and instrumentation all just consume that signal. If you don't have one, no amount of staring at code will save you.

Spend disproportionate effort here. **Be aggressive. Be creative. Refuse to give up.**

### Ways to construct one — try them in roughly this order

1. **Failing test** at whatever seam reaches the bug — unit with a mock, integration with the `//go:build integration` tag, or end-to-end.
2. **`go test -run <pattern>`** invocation that isolates the failing test.
3. **CLI invocation** — run the specific binary (`go run cmd/<name>/main.go`) with fixture inputs, diff against expected output.
4. **Headless browser script** (Playwright) — drives the web UI, asserts on DOM/console/network if the bug is in the UI.
5. **Replay a captured trace.** Save a real payload (bar data, order JSON, Alpaca response) to disk; replay through the code path in a test.
6. **Throwaway harness.** Spin up a minimal subset (one package, mocked dependencies) that exercises the bug path with a single function call in `TestXxx`.
7. **Property / fuzz loop.** If the bug is "sometimes wrong output", use `testing/quick` or write a loop that runs 1000 random inputs and looks for the failure mode.
8. **Bisection harness.** If the bug appeared between two commits, `git bisect run` with a script that `go test -run <pattern>` and checks the exit code.
9. **Differential loop.** Run the same input through old-version vs new-version (or two configs) and diff outputs.
10. **HITL bash script.** Last resort. If a human must click, drive _them_ with `scripts/hitl-loop.template.sh` so the loop is still structured. Captured output feeds back to you.

Build the right feedback loop, and the bug is 90% fixed.

### Iterate on the loop itself

Treat the loop as a product. Once you have _a_ loop, ask:

- Can I make it faster? (Cache setup, skip unrelated init, narrow the test scope.)
- Can I make the signal sharper? (Assert on the specific symptom, not "didn't crash".)
- Can I make it more deterministic? (Pin time with `time.Now` injection, seed RNG, isolate filesystem, freeze network with a mock.)

A 30-second flaky loop is barely better than no loop. A 2-second deterministic loop is a debugging superpower.

### Non-deterministic bugs

The goal is not a clean repro but a **higher reproduction rate**. Loop the trigger 100×, parallelise, add stress, narrow timing windows, inject sleeps. A 50%-flake bug is debuggable; 1% is not — keep raising the rate until it's debuggable.

### Go-specific tools

- **`go test -v -run <pattern>`** — run specific tests by name pattern
- **`go test -count=100 -run <pattern>`** — run 100× to surface flakiness
- **`delve`** (`dlv debug`, `dlv test`) — step through if the bug path is complex
- **`pprof`** (`go test -bench` + `-cpuprofile`) — for performance regressions
- **`GODEBUG`** env vars — `GODEBUG=gctrace=1` for GC debugging, `GODEBUG=http2debug=2` for HTTP/2
- **`-race` flag** — `go test -race ./...` for data race detection

### When you genuinely cannot build a loop

Stop and say so explicitly. List what you tried. Ask the user for: (a) access to whatever environment reproduces it, (b) a captured artifact (API response dump, log dump, stack trace), or (c) permission to add temporary instrumentation. Do **not** proceed to hypothesise without a loop.

Do not proceed to Phase 2 until you have a loop you believe in.

## Phase 2 — Reproduce

Run the loop. Watch the bug appear.

Confirm:

- [ ] The loop produces the failure mode the **user** described — not a different failure that happens to be nearby. Wrong bug = wrong fix.
- [ ] The failure is reproducible across multiple runs (or, for non-deterministic bugs, reproducible at a high enough rate to debug against).
- [ ] You have captured the exact symptom (error message, wrong output, slow timing) so later phases can verify the fix actually addresses it.

Do not proceed until you reproduce the bug.

## Phase 3 — Hypothesise

Generate **3–5 ranked hypotheses** before testing any of them. Single-hypothesis generation anchors on the first plausible idea.

Each hypothesis must be **falsifiable**: state the prediction it makes.

> Format: "If <X> is the cause, then <changing Y> will make the bug disappear / <changing Z> will make it worse."

If you cannot state the prediction, the hypothesis is a vibe — discard or sharpen it.

**Show the ranked list to the user before testing.** They often have domain knowledge that re-ranks instantly ("we just deployed a change to #3"), or know hypotheses they've already ruled out. Cheap checkpoint, big time saver. Don't block on it — proceed with your ranking if the user is AFK.

## Phase 4 — Instrument

Each probe must map to a specific prediction from Phase 3. **Change one variable at a time.**

Tool preference:

1. **`delve` / breakpoint** — one breakpoint beats ten logs if the environment supports it.
2. **`slog` / `log.Printf`** — targeted logs at the boundaries that distinguish hypotheses.
3. Never "log everything and grep".

**Tag every debug log** with a unique prefix, e.g. `slog.Debug("bug-a4f2: bars returned", "count", len(bars))`. Cleanup at the end becomes a single grep for `bug-`. Untagged logs survive; tagged logs die.

**Perf branch.** For performance regressions, logs are usually wrong. Instead: establish a baseline measurement (`go test -bench`, `pprof`), then bisect. Measure first, fix second.

## Phase 5 — Fix + regression test

Write the regression test **before the fix** — but only if there is a **correct seam** for it.

A correct seam is one where the test exercises the **real bug pattern** as it occurs at the call site. If the only available seam is too shallow (unit test that can't replicate the chain that triggered the bug), a regression test there gives false confidence.

**If no correct seam exists, that itself is the finding.** Note it. The codebase architecture is preventing the bug from being locked down. This suggests a refactoring need — consider [deep-modules.md](../tdd/deep-modules.md) and [interface-design.md](../tdd/interface-design.md) from the TDD skill to create a proper seam.

If a correct seam exists:

1. Turn the minimised repro into a failing test at that seam.
2. Watch it fail.
3. Apply the fix.
4. Watch it pass.
5. Re-run the Phase 1 feedback loop against the original (un-minimised) scenario.

## Phase 6 — Cleanup + post-mortem

Required before declaring done:

- [ ] Original repro no longer reproduces (re-run the Phase 1 loop)
- [ ] Regression test passes (or absence of seam is documented)
- [ ] All `bug-...` tagged instrumentation removed
- [ ] Throwaway test files / scripts deleted
- [ ] The hypothesis that turned out correct is stated in the commit message — so the next debugger learns

**Then ask: what would have prevented this bug?** If the answer involves architectural change (no good test seam, tangled callers, hidden coupling), flag it as a refactoring candidate for the next implementation cycle. Make the recommendation **after** the fix is in, not before — you have more information now than when you started.
