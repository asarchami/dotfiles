# Structs & Interfaces — Depth

## Type Assertions & Type Switches

### Safe Type Assertion

Type assertions MUST use the comma-ok form to avoid panics:

```go
// Good — safe
s, ok := val.(string)
if !ok {
    // handle
}

// Bad — panics if val is not a string
s := val.(string)
```

### Type Switch

Discover the dynamic type of an interface value:

```go
switch v := val.(type) {
case string:
    fmt.Println(v)
case int:
    fmt.Println(v * 2)
case io.Reader:
    io.Copy(os.Stdout, v)
default:
    fmt.Printf("unexpected type %T\n", v)
}
```

### Optional Behavior with Type Assertions

Check if a value supports additional capabilities without requiring them upfront:

```go
type Flusher interface {
    Flush() error
}

func writeData(w io.Writer, data []byte) error {
    if _, err := w.Write(data); err != nil {
        return err
    }
    // Flush only if the writer supports it
    if f, ok := w.(Flusher); ok {
        return f.Flush()
    }
    return nil
}
```

This pattern is used extensively in the standard library (e.g., `http.Flusher`, `io.ReaderFrom`).

## Struct & Interface Embedding

### Struct Embedding

Embedding promotes the inner type's methods and fields to the outer type — composition, not inheritance:

```go
type Logger struct {
    *slog.Logger
}

type Server struct {
    Logger
    addr string
}

// s.Info(...) works — promoted from slog.Logger through Logger
s := Server{Logger: Logger{slog.Default()}, addr: ":8080"}
s.Info("starting", "addr", s.addr)
```

The receiver of promoted methods is the _inner_ type, not the outer. The outer type can override by defining its own method with the same name.

### When to Embed vs Named Field

| Use | When |
| --- | --- |
| **Embed** | You want to promote the full API of the inner type — the outer type "is a" enhanced version |
| **Named field** | You only need the inner type internally — the outer type "has a" dependency |

```go
// Embed — Server exposes all http.Handler methods
type Server struct {
    http.Handler
}

// Named field — Server uses the store but doesn't expose its methods
type Server struct {
    store *DataStore
}
```

## Struct Field Tags

Use field tags for serialization control. Exported fields in serialized structs MUST have field tags:

```go
type Order struct {
    ID        string    `json:"id"         db:"id"`
    UserID    string    `json:"user_id"    db:"user_id"`
    Total     float64   `json:"total"      db:"total"`
    Items     []Item    `json:"items"      db:"-"`
    CreatedAt time.Time `json:"created_at" db:"created_at"`
    DeletedAt time.Time `json:"-"          db:"deleted_at"`
    Internal  string    `json:"-"          db:"-"`
}
```

| Directive               | Meaning                                     |
| ----------------------- | -------------------------------------------- |
| `json:"name"`           | Field name in JSON output                   |
| `json:"name,omitempty"` | Omit field if zero value                    |
| `json:"-"`              | Always exclude from JSON                    |
| `json:",string"`        | Encode number/bool as JSON string           |
| `db:"column"`           | Database column mapping (sqlx, etc.)        |
| `yaml:"name"`           | YAML field name                             |
| `xml:"name,attr"`       | XML attribute                               |
| `validate:"required"`   | Struct validation (go-playground/validator) |

## Preventing Struct Copies with `noCopy`

Some structs must never be copied after first use (e.g., those containing a mutex, a channel, or internal pointers). Embed a `noCopy` sentinel to make `go vet` catch accidental copies:

```go
// noCopy may be added to structs which must not be copied after first use.
// See https://pkg.go.dev/sync#noCopy
type noCopy struct{}

func (*noCopy) Lock()   {}
func (*noCopy) Unlock() {}

type ConnPool struct {
    noCopy noCopy
    mu     sync.Mutex
    conns  []*Conn
}
```

`go vet` reports an error if a `ConnPool` value is copied (passed by value, assigned, etc.). This is the same technique the standard library uses for `sync.WaitGroup`, `sync.Mutex`, `strings.Builder`, and others.

Always pass these structs by pointer:

```go
// Good
func process(pool *ConnPool) { ... }

// Bad — go vet will flag this
func process(pool ConnPool) { ... }
```
