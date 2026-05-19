# Go Refactoring Patterns

After the TDD cycle (all tests GREEN), look for these refactoring opportunities:

## Extract to Package

When a type or function accumulates enough logic, extract it into its own `internal/` package:

```go
// Before: inline in service
type symbolStore struct { ... }
func (s *symbolStore) Create(ctx, symbol) error { ... }

// After: extracted to internal/symbol/
import "github.com/ali/trading_bot/internal/symbol"

store := symbol.NewStore(db)
```

## Deepen a Module

When a package's interface is large but its implementation is thin, look for complexity you can pull **into** the module rather than exposing:

- Inline helpers into the package instead of exporting more functions
- Add internal types that simplify the exported API
- Example: `internal/exchange/` should handle rate-limit retry internally rather than requiring callers to implement retry

## Extract Interface

When a concrete type is used as a dependency, extract the interface that consumers actually need:

```go
// Before
func NewTicker(ex *alpaca.Client) *Ticker

// After
type Exchange interface {
    Bars(ctx, symbol, start, end, interval) ([]Bar, error)
}
func NewTicker(ex Exchange) *Ticker
```

## Inline the Obvious

Don't over-abstract. If a one-line helper is only used once and adds no clarity, inline it.

## Apply Go Idioms

- Replace `if err != nil { return err }` chains with proper error wrapping: `fmt.Errorf("doing x: %w", err)`
- Use `errors.Is()` / `errors.As()` for sentinel error matching
- Prefer `range` over index loops
- Prefer table-driven tests over repeated test functions

## What New Code Reveals

New code often reveals awkwardness in existing code. After implementing a slice:

- Does the new code fight against an existing interface? Redesign it.
- Is there duplication between the new code and existing patterns? Extract.
- Does the new code suggest a missing abstraction? Add it.
