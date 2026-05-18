# Interface Design for Testability (Go)

## 1. Constructor Injection

Accept dependencies via constructor, not by creating them internally:

```go
// Testable
type TickerService struct {
    exchange exchange.Exchange
    db       db.Store
}

func NewTickerService(exchange exchange.Exchange, db db.Store) *TickerService {
    return &TickerService{exchange: exchange, db: db}
}

// Hard to test
func NewTickerService() *TickerService {
    exchange := alpaca.NewClient(os.Getenv("API_KEY"))
    db := postgres.NewStore(os.Getenv("DATABASE_URL"))
    return &TickerService{exchange: exchange, db: db}
}
```

## 2. Accept Interfaces, Return Structs

Functions/methods should accept interface parameters and return concrete types:

```go
// Good
func NewTickerService(ex exchange.Exchange, store db.Store) *TickerService

// Avoid (accepting concrete types)
func NewTickerService(ex *alpaca.Client, store *postgres.Store) *TickerService
```

## 3. Small Interfaces

Prefer interfaces with 1-3 methods. Define them at the consumer site (in the package that needs them):

```go
// Defined at consumer site — only what's needed
type BarReader interface {
    Bars(ctx context.Context, symbol string, start, end time.Time, interval string) ([]Bar, error)
}

type OrderPlacer interface {
    SubmitOrder(ctx context.Context, order Order) (string, error)
}
```

## 4. Return Results, Not Side Effects

Functions that compute data are easier to test than functions that mutate state:

```go
// Testable
func CalculatePositionSize(equity float64, riskPercent float64, stopDistance float64) (float64, error)

// Harder to test
func (p *Portfolio) AllocatePosition(symbol string, riskPercent float64)
```

## 5. Go Interface Conventions

- Name interfaces with the `-er` suffix where natural: `Reader`, `Writer`, `Store`, `Logger`
- Define interfaces in the package that **uses** them, not the package that implements them
- Keep interface definitions close to where they're consumed
- An interface with one method is perfectly fine (`io.Reader` style)
