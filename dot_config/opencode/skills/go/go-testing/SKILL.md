---
name: go-testing
description: "Go testing — constrain behavior with executable specifications: table-driven tests, testify suites, mocks, unit and integration tests, benchmarks, coverage, parallel tests, fuzzing, fixtures, goleak, snapshots, CI. Use when writing new tests, reviewing a PR's test changes, auditing a suite for gaps or flakiness, or debugging a failing or flaky test."
license: MIT
---

# Go Testing

**Leading word: constrain.** Tests are executable specifications — they **constrain** observable behavior, not coverage targets. Every test pins one contract with the smallest, fastest, most deterministic assertion that proves it; write it so a regression fails loudly and a refactor that preserves behavior stays green.

## Steps — write tests

1. **Choose the test package.** Same-package `package foo` (white-box) reaches unexported internals; test package `package foo_test` (black-box) pins only the public API.

   *Done when: the package clause matches whether you assert internals or contracts.*

2. **Structure as table-driven with named subtests.** Every case has a `name` passed to `t.Run` — diagnostics and `-run` filtering depend on it.

   *Done when: each scenario carries a name, runs under `t.Run`, and its failure message names the inputs.*

3. **Keep unit tests fast, isolated, deterministic.** Under a millisecond, no network, no filesystem, no sleeping. Anything touching external systems goes behind `//go:build integration`.

   *Done when: `go test ./...` finishes in seconds and a rerun gives identical results.*

4. **Mock interfaces, not concrete types.** Define the interface where it's consumed and stub only the behavior the code under test needs. See [Mocking](./references/mocking.md) for fixtures and time mocking.

   *Done when: every mock is an interface stub, never a concrete type.*

5. **Use `require` for setup, `assert` for behavior.** Testify is a helper, not a replacement for the standard library.

   *Done when: a failed precondition aborts the test immediately; a failed assertion reports and continues.*

6. **Verify leaks and races for concurrent code.** `goleak.VerifyTestMain` in `TestMain` for goroutine-heavy packages; `go test -race ./...` in CI.

   *Done when: the race detector is clean and the suite leaks no goroutines.*

7. **Add examples and fuzz seeds where they document.** `ExampleFoo` with an `// Output:` comment runs under `go test`; `FuzzFoo` with a seeded corpus hunts edge cases.

   *Done when: each public function with non-obvious behavior has a runnable example and parsers or hot paths have a fuzz target.*

## Steps — review a PR's test changes

1. **Cover the diff.** Every new branch and error path has an assertion that would fail without it.

   *Done when: deleting the new behavior fails a test.*

2. **Check assertion quality.** Assertions target observable contracts, not implementation details; no over-mocking that pins internals.

   *Done when: each assertion checks what a caller observes, not how it was produced.*

3. **Check structure.** Named subtests, independent ordering, correct package choice (black-box preferred).

   *Done when: tests run in isolation and `go test ./... -shuffle=on` stays green.*

4. **Check for flakiness patterns.** Timing sleeps, port binds, and shared mutable state between tests.

   *Done when: `go test -count=10 ./...` passes deterministically.*

## Steps — audit a suite for gaps

1. **Map behavior to tests.** Which contracts are unpinned? Which are only pinned by integration tests?

   *Done when: every exported behavior has a test or a documented reason not to.*

2. **Check isolation.** Build tags separate integration from unit; no test touches shared or production-like state.

   *Done when: the fast unit run has zero external dependencies.*

3. **Check leaks, races, and ordering.** Run goleak, `-race`, and `-shuffle` across the suite.

   *Done when: all three checks pass on the whole suite, not just the new tests.*

4. **Check implementation coupling.** Tests that break on an innocent refactor signal over-mocking or internals-assertion.

   *Done when: no test asserts unexported behavior without a white-box reason.*

## Steps — debug a failing or flaky test

1. **Reproduce reliably.** Isolate with `-run 'TestName/subtest'`; for flaky tests use `-count=10`.

   *Done when: you can trigger the failure on demand.*

2. **Minimize.** Trim the case to the smallest input that still fails.

   *Done when: removing any part of the setup makes it pass.*

3. **Trace the root cause** into production code or test setup — the test is evidence, not the enemy.

   *Done when: you can explain why the current code fails, not just where.*

4. **Fix and lock it in.** The reproduction becomes a regression test.

   *Done when: the regression test fails on the old code and passes on the new.*

## Reference

### Naming conventions

```go
func TestAdd(t *testing.T) { ... }               // function test
func TestMyStruct_MyMethod(t *testing.T) { ... } // method test
func BenchmarkAdd(b *testing.B) { ... }          // benchmark
func ExampleAdd() { ... }                        // example (has // Output: comment)
func FuzzAdd(f *testing.F) { ... }               // fuzz test
```

### Table-driven tests

```go
func TestCalculatePrice(t *testing.T) {
    tests := []struct {
        name      string
        quantity  int
        unitPrice float64
        expected  float64
    }{
        {name: "single item", quantity: 1, unitPrice: 10.0, expected: 10.0},
        {name: "bulk discount - 100 items", quantity: 100, unitPrice: 10.0, expected: 900.0},
        {name: "zero quantity", quantity: 0, unitPrice: 10.0, expected: 0.0},
    }
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got := CalculatePrice(tt.quantity, tt.unitPrice)
            if got != tt.expected {
                t.Errorf("CalculatePrice(%d, %.2f) = %.2f, want %.2f", tt.quantity, tt.unitPrice, got, tt.expected)
            }
        })
    }
}
```

### Parallel tests

```go
func TestParallelOperations(t *testing.T) {
    tests := []struct{ name string; data []byte }{
        {"small data", make([]byte, 1024)},
        {"medium data", make([]byte, 1024*1024)},
    }
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            t.Parallel()
            if got := Process(tt.data); got == nil {
                t.Errorf("Process(%q) returned nil", tt.name)
            }
        })
    }
}
```

### Goroutine leak detection with goleak

```go
func TestMain(m *testing.M) {
    goleak.VerifyTestMain(m)
}
```

Exclude goroutines that predate the test with `goleak.IgnoreCurrent()`, or verify a single test with `defer goleak.VerifyNone(t)`.

### testing/synctest (Go 1.24+)

> **Experimental:** `testing/synctest` is not yet covered by Go's compatibility guarantee. Its API may change. For a stable alternative, use `clockwork` (see [Mocking](./references/mocking.md)).

Deterministic time for concurrent code: synthetic time advances only when all goroutines are blocked, so `time.Sleep`, `time.After`, and `time.Ticker` become ordering-predictable. Use it for time-based concurrent code, race reproduction, and timing-flaky tests:

```go
synctest.Run(func(t *testing.T) {
    ch := make(chan int, 1)
    go func() {
        time.Sleep(50 * time.Millisecond)
        ch <- 42
    }()
    select {
    case v := <-ch:
        if v != 42 { t.Errorf("got %d", v) }
    case <-time.After(100 * time.Millisecond):
        t.Fatal("timeout occurred")
    }
})
```

### Fuzzing

```go
func FuzzReverse(f *testing.F) {
    f.Add("hello")
    f.Add("")
    f.Add("a")
    f.Fuzz(func(t *testing.T, input string) {
        reversed := Reverse(input)
        if input != Reverse(reversed) {
            t.Errorf("Reverse(Reverse(%q)) = %q", input, reversed)
        }
    })
}
```

### Examples as executable documentation

```go
func ExampleCalculatePrice() {
    price := CalculatePrice(100, 10.0)
    fmt.Printf("Price: %.2f\n", price)
    // Output: Price: 900.00
}
```

### Benchmarks

```go
func BenchmarkFibonacci(b *testing.B) {
    for _, size := range []int{10, 20, 30} {
        b.Run(fmt.Sprintf("n=%d", size), func(b *testing.B) {
            b.ReportAllocs()
            for i := 0; i < b.N; i++ {
                Fibonacci(size)
            }
        })
    }
}
```

→ See `go-performance` for `b.Loop()`, `benchstat`, profiling from benchmarks, and CI regression detection.

### Integration tests

```go
//go:build integration

func TestDatabaseIntegration(t *testing.T) {
    db, err := sql.Open("postgres", os.Getenv("DATABASE_URL"))
    if err != nil {
        t.Fatal(err)
    }
    defer db.Close()
    // real database operations
}
```

Run with `go test -tags=integration ./...`. For Docker Compose fixtures, SQL schemas, and integration suites, see [Integration Testing](./references/integration-testing.md).

### Pointers

- [HTTP Testing](./references/http-testing.md) — `httptest` handler tests: bodies, query params, headers, status codes
- [Mocking](./references/mocking.md) — mock patterns, test fixtures, time mocking (`clockwork`)
- [Helpers](./references/helpers.md) — timeout helpers that panic with caller location
- Linters: `thelper`, `paralleltest`, `testifylint` enforce these practices — see `go-lint`

### Quick reference

```bash
go test ./...                          # all tests
go test -run TestName ./...            # specific test by exact name
go test -run TestName/subtest ./...    # subtests within a test
go test -run 'Test(Add|Sub)' ./...     # multiple tests (regexp OR)
go test -run '.*Validation.*' ./...    # tests containing substring
go test -run '/(unit|integration)' ./... # filter by subtest name
go test -race ./...                    # race detection
go test -shuffle=on ./...              # order-independence check
go test -count=10 ./...                # flakiness check
go test -cover ./...                   # coverage summary
go test -bench=. -benchmem ./...       # benchmarks
go test -fuzz=FuzzName ./...           # fuzzing
go test -tags=integration ./...        # integration tests
```

Coverage:

```bash
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out          # view in HTML
go tool cover -func=coverage.out          # coverage by function
go tool cover -func=coverage.out | grep total
```

## Watch for

| Mistake | Fix |
| --- | --- |
| Subtests without names (unclear diffs, unfilterable) | Name every case, run via `t.Run` |
| Order-dependent tests | Each test independently runnable; verify with `-shuffle=on` |
| Assertions on internals or concrete mocks | Black-box contracts, interface mocks |
| `assert` where a failure should abort setup | `require` for setup, `assert` for behavior |
| Timing-based waits | Deterministic time (`synctest`, `clockwork`) |
| Integration tests in the fast loop | `//go:build integration` + `-tags=integration` |
| Goroutine leaks silently passing | `goleak.VerifyTestMain` in `TestMain` |
| Chasing a coverage percentage | Constrain behavior; coverage is a byproduct |
| Testing the stdlib or framework | Trust the framework, test your own code |

## Cross-references

- → See `go-stretchr-testify` for the testify API (assert, require, mock, suite)
- → See `go-concurrency` for goroutine leak detection and concurrent test patterns
- → See `go-database` for database integration test patterns
- → See `go-continuous-integration` for CI test configuration and GitHub Actions workflows
- → See `go-lint` for `thelper`, `paralleltest`, and `testifylint` enforcement
- → See `go-performance` for benchmarking methodology and regression detection
- → See `go-troubleshooting` for test-driven debugging of failing tests
