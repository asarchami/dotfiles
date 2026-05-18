# Go Testing Conventions

## Good Tests

**Integration-style**: Test through exported interfaces, not unexported internals.

```go
// GOOD: Tests observable behavior through the public API
func TestCheckoutProcessesValidCart(t *testing.T) {
    cart := NewCart()
    cart.Add(testProduct)
    result, err := Checkout(cart, testPaymentMethod)
    assert.NoError(t, err)
    assert.Equal(t, StatusConfirmed, result.Status)
}
```

Characteristics:

- Tests behavior callers care about
- Uses exported API only (unexported helpers tested indirectly)
- Survives internal refactors
- Describes WHAT, not HOW
- One assertion or logical expectation per test

## Table-Driven Tests

Table-driven tests are the idiomatic Go pattern for testing multiple cases:

```go
func TestCalculateDiscount(t *testing.T) {
    tests := []struct {
        name     string
        cart     Cart
        expected Discount
        wantErr  bool
    }{
        {name: "empty cart", cart: Cart{}, expected: Discount{}, wantErr: true},
        {name: "loyalty discount", cart: Cart{Total: 100, LoyaltyTier: 3}, expected: Discount{Percent: 10}, wantErr: false},
        {name: "no discount below threshold", cart: Cart{Total: 10}, expected: Discount{Percent: 0}, wantErr: false},
    }
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            result, err := CalculateDiscount(tt.cart)
            if tt.wantErr {
                assert.Error(t, err)
                return
            }
            assert.NoError(t, err)
            assert.Equal(t, tt.expected, result)
        })
    }
}
```

Use `t.Run` for subtests — they run as separate test entries in `go test -v` output.

## testify/assert vs testify/require

| Package | When to use |
|---------|------------|
| `assert` | Failure doesn't prevent further checks |
| `require` | Failure should abort the test immediately (nil pointer, setup failure) |

```go
// require — test can't continue without this
user, err := CreateUser(ctx, validInput)
require.NoError(t, err)
require.NotNil(t, user)

// assert — test can continue checking other things
assert.Equal(t, "Alice", user.Name)
assert.True(t, user.Active)
```

## Integration Tests

Use the `//go:build integration` build tag to separate integration tests from unit tests:

```go
//go:build integration

package db_test

import (
    "testing"
    "github.com/stretchr/testify/require"
)

func TestPostgresStore_CreateSymbol(t *testing.T) {
    db := setupTestDB(t)
    defer db.Close()

    s, err := db.CreateSymbol(context.Background(), &Symbol{...})
    require.NoError(t, err)
    require.NotNil(t, s)
}
```

Run with:

```sh
go test -tags=integration ./...
```

Integration tests should use a test helper (`setupTestDB`) that handles connection and cleanup. Never commit test credentials.

## Bad Tests

**Implementation-detail tests**: Coupled to internal structure.

```go
// BAD: Tests implementation detail (mocked internal collaborators)
func TestCheckoutCallsPaymentProcess(t *testing.T) {
    mockPay := new(MockPaymentService)
    mockPay.On("Process", mock.Anything).Return(nil)
    svc := NewCheckoutService(mockPay)
    svc.Checkout(cart)
    mockPay.AssertCalled(t, "Process", cart.Total)
}
```

Red flags:

- Mocking internal collaborators
- Testing unexported functions directly
- Asserting on call counts or order
- Test breaks when refactoring without behavior change
- Test name describes HOW not WHAT

```go
// BAD: Bypasses interface to verify by querying the database directly
func TestCreateUserSavesToDatabase(t *testing.T) {
    CreateUser(ctx, "Alice")
    var name string
    db.QueryRow("SELECT name FROM users WHERE name=$1", "Alice").Scan(&name)
    assert.Equal(t, "Alice", name)
}

// GOOD: Verifies through the public interface
func TestCreateUserMakesUserRetrievable(t *testing.T) {
    user, err := CreateUser(ctx, "Alice")
    require.NoError(t, err)
    retrieved, err := GetUser(ctx, user.ID)
    require.NoError(t, err)
    assert.Equal(t, "Alice", retrieved.Name)
}
```

## Test File Placement

- Unit tests live in the same package (`package foo`) for white-box testing of exported symbols, or `package foo_test` for black-box testing
- Integration tests in a separate `_test.go` file with the `//go:build integration` tag
- Test helpers and mocks in `testing.go` or `mock_test.go` files within the same package
