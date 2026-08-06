
> **Community default.** A company skill that explicitly supersedes `go-patterns` skill takes precedence.

# Go Anti-Patterns

"Clear is better than clever." — Go Proverbs

Every entry below is a code smell with a fix. Use as a scan checklist during audit or review.

---

## Quick reference

| # | Anti-pattern | Sev | Detection hint |
|---|--------------|-----|----------------|
| 1.1 | Interface pollution (5+ methods) | high | `interface` with 5+ methods |
| 1.2 | Preemptive interface (1 impl) | high | interface with single production impl, no mock |
| 1.3 | Chaining interfaces | high | interface method returns interface whose method returns interface |
| 1.4 | Opaque config | med | `type Config interface { Value(interface{}) interface{} }` |
| 1.5 | Returning interface from ctor | low | `func NewX() SomeInterface` |
| 2.1 | Single model (3+ tag types) | high | `json:"..." gorm:"..." validate:"..."` on same struct |
| 2.2 | Logic in handlers | high | validation/rules inside HTTP handler |
| 2.3 | Starting with DB schema | med | storage types named after join tables |
| 2.4 | Missing struct tags | low | serialized field without `json:"..."` |
| 2.5 | Premature DRY | med | shared abstraction before 3rd usage |
| 3.1 | Discarded errors | high | `_ = fn()` or `fn()` where fn returns error |
| 3.2 | Bare return | med | `return err` without `fmt.Errorf("...: %w", err)` |
| 3.3 | Log-and-return | med | same error logged AND returned |
| 3.4 | Panic for expected errors | high | `panic(err)` for I/O/validation |
| 3.5 | Direct error comparison | med | `err == sentinel` without `errors.Is` |
| 3.6 | Capitalized error string | low | `errors.New("Failed")` |
| 4.1 | Unnecessary blank id | low | `for _ = range` → `for range` |
| 4.2 | Useless return | low | final `return` in void function |
| 4.3 | Useless break | info | final `break` in switch case |
| 4.4 | Single-case select | low | `select { case x := <-ch: }` without default |
| 4.5 | Redundant nil slice check | info | `x != nil && len(x) != 0` → `len(x) != 0` |
| 4.6 | Wrapping fn literal | info | `fn := func(x int) int { return f(x) }` → `fn := f` |
| 4.7 | Loop append | low | `for _, v := range b { a = append(a, v) }` → `a = append(a, b...)` |
| 4.8 | Redundant make args | info | `make(chan int, 0)` → `make(chan int)` |
| 5.1 | Goroutine leak | high | `go func()` without stop mechanism |
| 5.2 | Mutex across I/O | high | `Lock()` ... DB call ... `Unlock()` |
| 5.3 | time.After in loop | med | `time.After(d)` inside for/select |
| 5.4 | Unbounded spawning | high | `go fn()` in loop without `errgroup.SetLimit` |
| 5.5 | Missing ctx.Done() | med | select without `<-ctx.Done()` |
| 5.6 | wg.Add in goroutine | med | `wg.Add(1)` inside `go func()` body |
| 6.1 | Evergreen test | high | test with no assertions or can't fail |
| 6.2 | Asserting irrelevant detail | med | `cmp.Equal` on whole struct for 1 field |
| 6.3 | Complicated table test | med | 7+ fields in test table struct |
| 6.4 | Violating encapsulation | high | exported fn only called from tests |
| 6.5 | assert.Len then index | high | `assert.Len(t, r, 1); r[0]` → `require.Len` |
| 6.6 | Missing goleak | med | goroutine packages without `goleak.VerifyTestMain` |
| 7.1 | init() for setup | med | `func init()` doing I/O |
| 7.2 | Mutable global state | high | `var x` mutated at runtime |
| 7.3 | Init closure | low | `var x = func() T { ... }()` |
| 8.1 | Valid iota at 0 | med | `StatusActive = iota` (0 = valid) → add `StatusUnknown` |
| 8.2 | Bool parameter soup | low | 2+ consecutive `bool` params → options struct |
| 8.3 | math/rand for secrets | high | `math/rand` for tokens/keys → `crypto/rand` |
| 9.1 | Verbose error exposure | high | `err.Error()` in HTTP response |
| 9.2 | No body size limit | med | POST without `http.MaxBytesReader` |
| 9.3 | Binding to 0.0.0.0 | low | `Addr: ":port"` → `Addr: "127.0.0.1:port"` |
| 9.4 | Hardcoded secrets | high | API key in source → env var |

---

## 1. Abstraction

### 1.1 Interface pollution
```go
type UserRepo interface { Find(ctx,id); FindAll(ctx); Save(ctx,*User); Update(ctx,*User); Delete(ctx,id); Count(ctx); FindByEmail(ctx,email); FindByRole(ctx,role) }
```
Split into 1-3 method interfaces (`UserReader`, `UserWriter`, `UserDeleter`). Compose where needed.

### 1.2 Preemptive interface
```go
interface Calculator { Compute(ctx, input) (*Result, error) } // 1 impl, no test mock
```
Start concrete. Extract when 2nd impl or mock is needed.

### 1.3 Chaining interfaces
```go
type Parser interface { Parse() Result }
type Client interface { Fetch() Parser }
type Service interface { Client() Client }
```
Return concrete types. Accept interfaces.

### 1.4 Opaque config
```go
type Config interface { Value(key interface{}) interface{} }
```
Use a concrete typed struct. Inject via constructor.

### 1.5 Returning interface from ctor
```go
func New() ServiceInterface // returns interface
```
Return `*Service`. Let caller assign to interface.

---

## 2. Coupling

### 2.1 Single model
```go
type User struct {
    ID           int    `json:"id" gorm:"primaryKey" validate:"required"`
    PasswordHash string `json:"-" gorm:"column:password_hash"`
}
```
Separate models for HTTP, DB, domain. Write conversion functions.

### 2.2 Logic in handlers
Validation, permissions, calculations inside HTTP handlers. Extract to service layer.

### 2.3 Starting with DB schema
`MembershipStorage` mirroring a join table. Model storage methods around domain behavior: `teamStorage.AddMember(...)`.

### 2.4 Missing struct tags
```go
type Email struct { ID int; Address string; Primary bool }
```
Always add tags even when name matches: `gorm:"column:address"`.

### 2.5 Premature DRY
> "A little copying is better than a little dependency." Duplication is harmless compared to the wrong abstraction.

---

## 3. Error handling

### 3.1 Discarded errors
```go
json.Unmarshal(data, &result)  // error unchecked
rows, _ := db.Query(ctx, ...)
```
Every error is a required branch. Defer `Close()` is the only accepted exception.

### 3.2 Bare return
```go
return err  // no context
```
`return fmt.Errorf("doing X: %w", err)` at every layer.

### 3.3 Log-and-return
```go
slog.Error("failed", "err", err); return fmt.Errorf("...: %w", err)
```
Log at boundaries (main, handler). Wrap and return everywhere else.

### 3.4 Panic for expected errors
`panic` is for programmer errors (nil deref, bounds), not network/I/O/validation. Return error.

### 3.5 Direct comparison
`err == sql.ErrNoRows` → `errors.Is(err, sql.ErrNoRows)`. `err.(*Type)` → `errors.As(err, &ve)`.

### 3.6 Capitalized error strings
`errors.New("Failed to connect")` → `errors.New("connection refused")`. Lowercase, no punctuation.

---

## 4. Code organization

### 4.1 Unnecessary blank id
`for _ = range x` → `for range x`. `x, _ := m["k"]` → `x := m["k"]`. `_ = <-ch` → `<-ch`.

### 4.2 Useless return
Final `return` in void function — delete it.

### 4.3 Useless break
Final `break` in switch case — delete it (Go doesn't fall through).

### 4.4 Single-case select
`select { case x := <-ch: }` → `x := <-ch`. Add `default` for non-blocking.

### 4.5 Redundant nil slice check
`if x != nil && len(x) != 0` → `if len(x) != 0`. `len(nil_slice) == 0`.

### 4.6 Wrapping fn literal
`fn := func(x int) int { return f(x) }` → `fn := f`.

### 4.7 Loop append
`for _, v := range b { a = append(a, v) }` → `a = append(a, b...)`.

### 4.8 Redundant make
`make(chan int, 0)` → `make(chan int)`. `make([]int, 1, 1)` → `make([]int, 1)`.

---

## 5. Concurrency

### 5.1 Goroutine leak
Every `go func()` needs: context cancellation, done channel, or WaitGroup. Checklist: can I cancel it? can I wait for it? can I signal it?

### 5.2 Mutex across I/O
Holding `Lock()` across DB/HTTP blocks all goroutines. Snapshot under lock, do I/O outside.

### 5.3 time.After in loop
```go
for { select { case <-time.After(5*time.Second): ... } }
```
```go
t := time.NewTimer(5*time.Second); defer t.Stop()
for { t.Reset(5*time.Second); select { case <-t.C: ... } }
```

### 5.4 Unbounded spawning
```go
for _, item := range items { go process(item) }
```
```go
g, ctx := errgroup.WithContext(ctx); g.SetLimit(10)
for _, item := range items { g.Go(func() error { return process(item) }) }
```

### 5.5 Missing ctx.Done()
Every `select` in a goroutine must include `case <-ctx.Done(): return`.

### 5.6 wg.Add in goroutine
```go
go func() { wg.Add(1); defer wg.Done(); ... }() // Wait may return before Add runs
```
`wg.Add(1)` before `go func()`.

---

## 6. Testing

### 6.1 Evergreen test
Test passes even when code is removed. Fix: write test first, see it fail (red phase).

### 6.2 Asserting irrelevant detail
`cmp.Equal(got, want)` on full struct when only one field matters. Assert specific fields.

### 6.3 Complicated table test
7+ fields in test struct, many conditional. Split distinct scenarios into separate test functions.

### 6.4 Violating encapsulation to test
Exported fn only used in tests. Test in same package (`package foo` not `package foo_test`) or through public API.

### 6.5 assert.Len then index
`assert.Len(t, r, 1); r[0]` panics if len != 1. Use `require.Len(t, r, 1)`.

### 6.6 Missing goleak
```go
func TestMain(m *testing.M) { goleak.VerifyTestMain(m) }
```

---

## 7. Config & packages

### 7.1 init() for setup
`func init()` doing I/O, connecting DB, panicking. Use explicit constructor: `New(dsn) (*Repo, error)`.

### 7.2 Mutable global state
`var x` mutated at runtime makes tests leak state. Move to per-instance, inject via constructor.

### 7.3 Init closure
```go
var loc = func() *time.Location { ...; panic(...) }()
```
```go
var once sync.Once; var loc *time.Location
func Location() *time.Location { once.Do(func() { ... }); return loc }
```

---

## 8. Enum & type

### 8.1 iota at valid value
```go
const ( StatusActive Status = iota ) // 0 = valid, uninitialized vars are "Active"
```
```go
const ( StatusUnknown Status = iota; StatusActive; StatusInactive )
```

### 8.2 Bool parameter soup
`CreateUser("Alice", true, false, true)` — what do the bools mean? Use options struct or functional options.

### 8.3 math/rand for secrets
```go
token := fmt.Sprintf("%x", rand.Uint64())
```
```go
b := make([]byte, 32); crypto.Read(b); hex.EncodeToString(b)
```

---

## 9. Security

### 9.1 Verbose error exposure
`http.Error(w, err.Error(), 500)` leaks internals. Log detail server-side, return generic.

### 9.2 No body size limit
```go
r.Body = http.MaxBytesReader(w, r.Body, 10<<20)
```
Add to all POST/PUT handlers.

### 9.3 Binding to 0.0.0.0
`Addr: ":8080"` binds all interfaces. Internal services use `127.0.0.1:`.

### 9.4 Hardcoded secrets
API keys, passwords in source → env vars or secret manager.

---

## Cross-references

`go-safety` | `go-concurrency` | `go-style` | `go-structs-interfaces` | `go-security` | `go-testing` | `go-patterns` | `go-safety` | `go-lint` | `go-lint`
