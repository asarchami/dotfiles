---
name: alpaca-broker
description: "Alpaca Broker API for building brokerage services and trading apps for end users. Covers account opening (KYC/KYB), funding (ACH, journals, wallets), trading, crypto, SSE events, corporate actions, IPOs, fixed income, portfolio rebalancing, statements, and sandbox testing."
user-invocable: true
license: MIT
metadata:
  author: opencode
  version: "1.0.0"
  openclaw:
    emoji: "🏦"
    homepage: https://docs.alpaca.markets/us/docs/about-broker-api
---

**Persona:** You are a fintech engineer building a brokerage platform. You treat the Broker API as the backend infrastructure for account management, funding, and trading on behalf of end users. You think in terms of multi-tenant architecture, KYC/AML compliance, and sandbox-to-production lifecycle.

**Thinking mode:** Use `ultrathink` for designing account opening flows, funding orchestration, and SSE event processing. Shallow reasoning misses compliance edge cases and funding race conditions.

## Base URLs

| Environment | URL |
|---|---|
| Live | `https://broker-api.alpaca.markets` |
| Sandbox | `https://broker-api.sandbox.alpaca.markets` |
| Auth (Live) | `https://authx.alpaca.markets` |
| Auth (Sandbox) | `https://authx.sandbox.alpaca.markets` |
| Market Data (Live) | `https://data.alpaca.markets` |
| Market Data (Sandbox) | `https://data.sandbox.alpaca.markets` |

## Authentication

Broker API uses **Client Credentials** (OAuth2). Not the legacy API key headers.

```go
type BrokerAuth struct {
    ClientID     string
    ClientSecret string
    token        string
    expiresAt    time.Time
}

func (a *BrokerAuth) Token(ctx context.Context) (string, error) {
    if a.token != "" && time.Now().Before(a.expiresAt) {
        return a.token, nil
    }
    form := url.Values{
        "grant_type":    {"client_credentials"},
        "client_id":     {a.ClientID},
        "client_secret": {a.ClientSecret},
    }
    req, _ := http.NewRequestWithContext(ctx, "POST",
        "https://authx.sandbox.alpaca.markets/v1/oauth2/token",
        strings.NewReader(form.Encode()))
    req.Header.Set("Content-Type", "application/x-www-form-urlencoded")

    resp, err := http.DefaultClient.Do(req)
    if err != nil {
        return "", err
    }
    defer resp.Body.Close()

    var r struct {
        AccessToken string `json:"access_token"`
        ExpiresIn   int    `json:"expires_in"`
    }
    json.NewDecoder(resp.Body).Decode(&r)

    a.token = r.AccessToken
    a.expiresAt = time.Now().Add(time.Duration(r.ExpiresIn) * time.Second)
    return a.token, nil
}
```

Tokens are valid for **15 minutes**. Cache them and reuse; do not request a new token per call.

## Rate Limits

- Standard: 1,000 RPM (requests per minute)
- Higher tiers available (StandardPlus3000: 3,000 RPM, StandardPlus5000: 5,000 RPM, StandardPlus10000: 10,000 RPM)
- 429 Too Many Requests: respect `Retry-After` header

## Endpoint Groups

### Account Management

| Method | Path | Description |
|---|---|---|
| POST | `/v1/accounts` | Create account with KYC |
| GET | `/v1/accounts/{id}` | Get account by ID |
| PATCH | `/v1/accounts/{id}` | Update account info |
| GET | `/v1/accounts` | List all accounts (paginated) |
| POST | `/v1/accounts/{id}/actions/close` | Close an account |

Account creation requires KYC data: `contact`, `identity`, `disclosures`, `agreements`. Use `created_after`/`created_before` for pagination of `GET /v1/accounts`.

### Account Opening (KYCaaS)

- Account statuses: `SUBMITTED`, `APPROVED`, `ONBOARDING`, `ACTIVE`, `REJECTED`, `CLOSED`
- Domestic (USA): SSN, DOB, address verification
- International: passport, proof of address
- IRA accounts: Traditional IRA, Roth IRA
- Data validations: pre-flight checks before submission

### Funding

| Method | Path | Description |
|---|---|---|
| POST | `/v1/accounts/{id}/transfers` | ACH transfer |
| GET | `/v1/accounts/{id}/transfers` | List transfers |
| POST | `/v1/accounts/{id}/journals` | Create journal (internal transfer) |
| GET | `/v1/accounts/{id}/journals` | List journals |
| GET | `/v1/accounts/{id}/wallets` | List crypto wallets |
| POST | `/v1/accounts/{id}/wallets` | Create crypto wallet |

### Trading

Broker API supports **all Trading API functionality** under the broker setup, plus additional broker-specific capabilities. See the `alpaca-trading` skill for order types, positions, and account activities.

Additional broker-specific trading features:
- Per-account trading configurations
- Account-level trading restrictions
- Multi-account order routing

### SSE Events

| Endpoint | Description |
|---|---|
| `GET /v1/events/trades` | Real-time trade updates (SSE) |
| `GET /v1/events/activities` | Account activities stream |
| `GET /v1/events/journals/status` | Journal status updates |
| `GET /v1/events/funding/status` | Funding status updates |
| `GET /v1/events/system` | System events |
| `GET /v1/events/admin/actions` | Admin action events |
| `GET /v1/events/account/status` | Account status events (KYCaaS) |
| `GET /v1/events/ipo` | IPO lifecycle events |

SSE events include comment lines (starting with `:`) for slow-client warnings and internal errors. Handle pagination with `since_id`/`until_id` query parameters for historical replay.

### Other

- **Corporate Actions**: mandatory (mergers, splits) and voluntary (tender offers, rights)
- **ACAT API**: Transfer positions between brokerages
- **IPOs**: Offerings, allocations, prospectus
- **Fixed Income**: Treasuries and corporate bonds
- **Statements & Confirms**: Account statements, trade confirmations, tax documents
- **Portfolio Rebalancing**: Automated portfolio rebalancing
- **LCT**: Local Currency Trading (15+ currencies)

## Error Handling

```go
type BrokerAPIError struct {
    StatusCode int
    Message    string
    Code       string // Alpaca error code
}

// Common HTTP statuses:
// 400 - validation error (check request body)
// 401 - authentication failure
// 403 - insufficient permissions
// 404 - resource not found
// 409 - conflict (e.g., duplicate account)
// 422 - KYC data validation failure
// 429 - rate limited
// 500 - internal error (retry with backoff)
```

## Testing with Sandbox

- Use `broker-api.sandbox.alpaca.markets` for all Broker API calls
- Use `authx.sandbox.alpaca.markets` for token issuance
- Sandbox supports full account creation flow with test KYC data
- Pre-funded test accounts available
- Reset sandbox data via dashboard
- See [Data Validations](https://docs.alpaca.markets/us/docs/data-validations) for test KYC values

### Example: Create a Test Account

```go
func createTestAccount(ctx context.Context, auth *BrokerAuth) (string, error) {
    token, err := auth.Token(ctx)
    // POST /v1/accounts with KYC data
    // See Data Validations doc for sandbox-compatible values
}
```
