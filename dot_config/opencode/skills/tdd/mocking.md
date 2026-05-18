# When to Mock

Mock at **system boundaries** only:

- External APIs (exchange APIs, payment processors)
- Databases (prefer a real test DB; mock the Store interface when unit-testing consumers)
- Time / random generation
- File system

Don't mock:

- Your own packages/modules
- Internal collaborators
- Anything you control

## testify/mock

Use `github.com/stretchr/testify/mock` for Go mocks at system boundaries:

```go
type MockExchange struct {
    mock.Mock
}

func (m *MockExchange) Bars(ctx context.Context, symbol string, start, end time.Time, interval string) ([]Bar, error) {
    args := m.Called(ctx, symbol, start, end, interval)
    return args.Get(0).([]Bar), args.Error(1)
}

func (m *MockExchange) SubmitOrder(ctx context.Context, order Order) (string, error) {
    args := m.Called(ctx, order)
    return args.String(0), args.Error(1)
}

func (m *MockExchange) Account(ctx context.Context) (Account, error) {
    args := m.Called(ctx)
    return args.Get(0).(Account), args.Error(1)
}
```

Usage:

```go
func TestTicker_PollsActiveSymbols(t *testing.T) {
    mockEx := new(MockExchange)
    mockEx.On("Bars", mock.Anything, "AAPL", mock.Anything, mock.Anything, mock.Anything).
        Return([]Bar{{Time: time.Now(), Close: 150.0}}, nil)

    svc := NewTickerService(mockEx, mockDB)
    // ...
    mockEx.AssertExpectations(t)
}
```

## When to Hand-Write Mocks

For interfaces with 1-3 methods, consider hand-written mocks instead of testify/mock:

```go
// Hand-written mock — simpler, no testify dependency
type mockStore struct {
    createFunc func(ctx context.Context, s Symbol) (Symbol, error)
}

func (m *mockStore) Create(ctx context.Context, s Symbol) (Symbol, error) {
    return m.createFunc(ctx, s)
}
```

Use testify/mock when:
- The interface has 4+ methods
- You need `AssertExpectations` (auto-verify every mock was called as expected)
- You need `mock.Anything` / `mock.MatchedBy` for flexible argument matching

Use hand-written mocks when:
- The interface is tiny (1-3 methods)
- You want zero external dependencies in the test
- Each test needs unique mock behavior (closures are clearer than testify's setup)

## Designing for Mockability

At system boundaries, design interfaces that are easy to mock:

**1. Use constructor injection (see [interface-design.md](interface-design.md))**

**2. Prefer task-specific methods over a generic `Execute`**

```go
// GOOD: Each method is independently mockable
type Exchange interface {
    Bars(ctx, symbol, start, end, interval) ([]Bar, error)
    SubmitOrder(ctx, order) (string, error)
    Account(ctx) (Account, error)
}

// BAD: Mocking requires type-switch logic inside the mock
type Exchange interface {
    Execute(ctx, req Request) (Response, error)
}
```
