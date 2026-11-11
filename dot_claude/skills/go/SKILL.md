---
name: go
description: Foundation for writing, reviewing, and refactoring Go code with the standard library — modern Go idioms (1.21 through 1.27), error handling, concurrency and context, API and type design, testing, and the verification gate. Use whenever touching .go files, go.mod, or Go tests, or when the user asks how to do something idiomatically in Go.
---

# Go

Standard library first. Reach for a third-party module only when the standard
library genuinely has no answer, and say so before adding it.

This skill covers only what an agent tends to get wrong by default: idioms that
changed after most training data was written, and the handful of rules that
separate working Go from correct Go. Everything else is ordinary Go knowledge.

## Before writing code

1. Read the `go` line in `go.mod`. Language features and some library behavior
   are gated by it, not by the installed toolchain. Do not use a feature newer
   than that line. Raising it is a decision for the user.
2. Look at how the surrounding package already does things (errors, logging,
   tests) and match it, unless it contradicts a rule below. Flag that conflict
   rather than silently picking one.
3. Use `go doc pkg.Symbol` to check an API before relying on memory. It is
   authoritative for the installed toolchain and costs one call.

## Verification gate

Run all of these before calling work done. Check each exit status directly,
never through a pipe into `tail` or `head`.

```sh
gofmt -l .            # must print nothing
go vet ./...
go fix -diff ./...    # exits non-zero if a modernizer has a suggestion
go test -race ./...
```

If the project has a `.golangci.yml`, also run `golangci-lint run`. `go vet`
is not optional: it catches real bugs, such as printf verb/argument mismatches,
that compile cleanly.

## Modern Go

Prefer these over the older forms. The version is the minimum `go` line.

| Instead of | Write | Since |
|---|---|---|
| `for i := 0; i < n; i++` | `for i := range n` | 1.22 |
| `v := v` before a closure in a loop | nothing; loop variables are per-iteration | 1.22 |
| hand-rolled min/max/clear helpers | built-in `min`, `max`, `clear` | 1.21 |
| `sort.Slice`, manual contains/index loops | `slices.Sort`, `slices.SortFunc`, `slices.Contains`, `slices.Index` | 1.21 |
| collecting map keys then sorting | `slices.Sorted(maps.Keys(m))` | 1.23 |
| returning a slice just to iterate it | return `iter.Seq[T]` / `iter.Seq2[K, V]` | 1.23 |
| `strings.Split` only to loop over parts | `strings.SplitSeq`, `strings.FieldsSeq`, `strings.Lines` | 1.24 |
| `strings.LastIndex` plus slicing | `strings.CutLast` (and `strings.Cut` for the first) | 1.27 |
| `var e *T; errors.As(err, &e)` | `e, ok := errors.AsType[*T](err)` | 1.26 |
| `x := v; p := &x` | `p := new(v)` (`new` takes an expression) | 1.26 |
| `wg.Add(1); go func() { defer wg.Done(); ... }()` | `wg.Go(func() { ... })` | 1.25 |
| `sync.Once` plus a package var | `sync.OnceValue`, `sync.OnceValues` | 1.21 |
| `atomic.AddInt64(&n, 1)` on a bare int | `atomic.Int64` and friends | 1.19 |
| third-party logger | `log/slog`; fan out with `slog.NewMultiHandler` (1.26) | 1.21 |
| third-party router for path params | `mux.HandleFunc("GET /items/{id}", h)` plus `r.PathValue("id")` | 1.22 |
| hand-rolled CSRF checks | `http.CrossOriginProtection` | 1.25 |
| `filepath.Join` on untrusted names | `os.OpenRoot(dir)` and the `*os.Root` methods | 1.24 |
| `json:",omitempty"` on structs and times | `omitzero`, which respects `IsZero()` | 1.24 |
| `encoding/json` in new code | `encoding/json/v2`: stricter by default (rejects invalid UTF-8 and duplicate names) | 1.27 |
| `github.com/google/uuid` | the standard `uuid` package; `uuid.NewV7()` for sortable IDs | 1.27 |
| `for b.N` loops in benchmarks | `for b.Loop() { ... }` | 1.24 |
| `context.Background()` in tests | `t.Context()`, cancelled when the test ends | 1.24 |
| `tools.go` with blank imports | `tool` directive in `go.mod`, run with `go tool name` | 1.24 |

Language features you can use where the `go` line allows: generic type aliases
(1.24), self-referential type constraints (1.26), and generic methods (1.27).
Interface methods still cannot have type parameters, and a generic method cannot
satisfy an interface.

Behavior that changed underneath old advice:

- An unreferenced `time.Timer` or `time.Ticker` is garbage-collected even if
  not stopped, and timer channels are unbuffered (1.23). `time.After` in a
  `select` loop no longer leaks. Still stop timers you own, for clarity.
- `GOMAXPROCS` respects the cgroup CPU limit on Linux (1.25). Don't add a
  third-party maxprocs library.
- `go fix` is the modernizer (1.26). Run `go fix ./...` to apply its fixes.

## Errors

- Wrap with context using `%w`: `fmt.Errorf("load config %q: %w", path, err)`.
  The context says what this function was doing, not "failed to" or "error".
- Handle each error exactly once: either return it, or log it and continue.
  Never both, because that produces duplicate logs.
- Sentinel errors (`var ErrNotFound = errors.New(...)`) are for conditions
  callers branch on. Custom types are for when callers need fields. Check them
  with `errors.Is` and `errors.AsType`, never `==` or a type assertion on a
  wrapped error.
- Combine independent failures with `errors.Join`, for example closing several
  resources.
- Return a non-nil error for "not found" rather than a nil pointer and nil
  error.
- `panic` is for programmer bugs and impossible states only, never for input or
  I/O errors. Do not recover except at a goroutine or request boundary.
- Never return a typed nil pointer as an `error`. The interface becomes
  non-nil. Return a literal `nil`.

## Concurrency and context

- Every goroutine needs an owner and a guaranteed way to stop: context
  cancellation, a closed channel, or the end of finite work. If you can't say
  how it stops, don't start it.
- `ctx context.Context` is the first parameter. Don't store a context in a
  struct. Pass it through every call that can block or do I/O.
- Use `context.WithoutCancel` for work that must outlive the request, such as
  audit writes, and `context.AfterFunc` for cleanup on cancellation (1.21).
  Prefer `WithTimeoutCause` and `WithCancelCause` so a cancellation explains
  itself.
- Only the sender closes a channel. Make ownership obvious from the signature
  (`<-chan T`, `chan<- T`).
- Use a mutex for shared state and a channel for handing over ownership or
  signalling. Don't build a mutex out of channels.
- Bound fan-out. Use a fixed worker count or a buffered channel as a semaphore,
  never one goroutine per input item from unbounded input.
- Maps are not safe for concurrent writes. Use a mutex. Reach for `sync.Map`
  only for its two documented cases: write-once/read-many keys, or disjoint key
  sets per goroutine.
- `sync.WaitGroup` does not propagate errors. If you need "first error cancels
  the rest", write it with a context and an error channel, or ask before adding
  `golang.org/x/sync/errgroup`.
- Graceful shutdown: `ctx, stop := signal.NotifyContext(ctx, os.Interrupt,
  syscall.SIGTERM)`, then `srv.Shutdown(shutdownCtx)` with its own timeout.

## Design

- Packages are named for what they provide (`order`, `queue`), never `util`,
  `common`, `helpers`, or `models`. Avoid stutter: `order.Service`, not
  `order.OrderService`.
- Accept interfaces, return concrete types. Define an interface in the package
  that uses it, keep it small, and only when there are two implementations or a
  test seam is needed. No interface "just in case".
- Make the zero value useful where you can (`var buf bytes.Buffer`,
  `var mu sync.Mutex`). Otherwise provide `New...` and document why.
- Use a plain constructor with required arguments. Add an options struct when
  configuration grows. Functional options are for libraries with many optional
  knobs, not internal code.
- Pointer receivers when the method mutates, or the struct is large or contains
  a mutex. Don't mix receiver kinds on one type.
- `internal/` for anything not meant to be imported from outside the module.
- Doc comments on every exported identifier start with its name.

## Pitfalls

- `append` may share the backing array. Clone (`slices.Clone`) before handing
  a slice to someone who will append, or before storing a caller's slice.
- Returning an internal slice or map exposes it to mutation. Return
  `slices.Clone` or `maps.Clone`, or an iterator.
- A nil map reads fine and panics on write. Initialize maps before writing.
- `defer` inside a loop runs at function exit, not per iteration. Move the loop
  body into a function.
- Always close `resp.Body`. Since 1.27, `Close` drains a bounded amount of
  unread body for connection reuse, so manual draining is rarely needed.
- `http.Client{}` and `http.Server{}` have no timeouts by default. Set
  `Timeout` on clients, and `ReadHeaderTimeout` at minimum on servers.
- Comparing floats with `==`, converting between integer sizes without range
  checks, and using `time.Now()` directly in logic (inject a clock or use
  `synctest`) all cause subtle bugs.

## Testing

Standard library `testing` only, unless the project already uses something else.

- Table-driven tests with `t.Run(tc.name, ...)` and a `name` field. Call
  `t.Parallel()` when cases are independent.
- `t.Helper()` in assertion helpers. `t.Cleanup` instead of `defer` in
  helpers. `t.TempDir()`, `t.Setenv()`, `t.Chdir()` (1.24), `t.Context()`.
- Compare with `slices.Equal`, `maps.Equal`, or `reflect.DeepEqual`. Report
  `got` before `want`: `t.Errorf("Parse(%q) = %v, want %v", in, got, want)`.
- Test time-dependent and concurrent code inside `synctest.Test(t, func(t
  *testing.T) { ... })` (1.25). Time is virtual, `synctest.Wait()` waits for
  goroutines to block, and `synctest.Sleep` (1.27) advances and settles in one
  call. Use `httptest.NewTestServer` (1.27) for an in-memory server inside a
  bubble. Never `time.Sleep` in tests to wait for goroutines.
- `httptest.NewRecorder` for handlers, `httptest.NewServer` for clients.
- `testing/fstest.MapFS` instead of real files where code accepts an `fs.FS`.
- Fuzz parsers and decoders with `func FuzzX(f *testing.F)`.
- Example functions (`func ExampleX()` with `// Output:`) double as documentation
  and as tests.
- Fakes over mocks: a small hand-written struct implementing the consumer's
  interface beats a generated mock.
