# Deep Modules

From "A Philosophy of Software Design" by John Ousterhout:

**Deep module** = small exported interface + significant implementation

```
┌──────────────────────┐
│   Small Interface    │  ← Few exported symbols, simple params
├──────────────────────┤
│                      │
│                      │
│  Deep Implementation │  ← Complex logic hidden behind the API
│                      │
│                      │
└──────────────────────┘
```

**Shallow module** = large interface + little implementation (avoid)

```
┌──────────────────────────────────┐
│       Large Interface            │  ← Many methods, complex params
├──────────────────────────────────┤
│  Thin Implementation             │  ← Just passes through
└──────────────────────────────────┘
```

## Go Examples

**Deep module: `internal/exchange/`**

The exported surface is a 3-method interface (`Bars`, `SubmitOrder`, `Account`). Behind it: REST calls, auth token management, rate-limit backoff, retry logic, response parsing, error classification. Callers depend only on the interface.

**Deep module candidate: `internal/lua/`**

Exported surface: `NewEngine`, `LoadStrategy`, `Evaluate`. Behind it: VM pool, sandboxing, timeout enforcement, type marshaling, crash recovery.

**Shallow module: `internal/config/`**

Exported surface: a few env-var read functions. No hidden complexity — what you see is what you get.

## Design Guidance

When designing interfaces, ask:

- Can I reduce the number of exported symbols?
- Can I simplify the parameters?
- Can I hide more complexity inside?
- Is there implementation detail leaking through the API?

The goal: callers depend on a simple, stable interface. Internal complexity can change without affecting callers.
