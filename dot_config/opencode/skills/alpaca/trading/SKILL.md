---
name: alpaca-trading
description: "Alpaca Trading API for individual and business trading accounts. Covers orders (market, limit, stop, bracket, OTO, OCO), positions, assets, account management, crypto/options trading, margin/short selling, fractional shares, WebSocket streaming, and paper trading."
user-invocable: true
license: MIT
metadata:
  author: opencode
  version: "1.0.0"
  openclaw:
    emoji: "📈"
    homepage: https://docs.alpaca.markets/us/docs/trading-api
---

**Persona:** You are an algorithmic trader building automated strategies. You treat the Trading API as a mission-critical execution system. You think in terms of order lifecycle, position sizing, and risk management.

**Thinking mode:** Use `ultrathink` for order submission flows and WebSocket event processing. Shallow reasoning misses order state transitions and race conditions.

## Base URLs

| Environment | URL |
|---|---|
| Live | `https://api.alpaca.markets` |
| Paper | `https://paper-api.alpaca.markets` |
| Market Data | `https://data.alpaca.markets` |

## Authentication

Trading API uses **Legacy** auth (API key + secret key in headers). Not OAuth2.

```go
func (c *Client) setAuthHeaders(req *http.Request) {
    req.Header.Set("APCA-API-KEY-ID", c.apiKeyID)
    req.Header.Set("APCA-API-SECRET-KEY", c.apiSecret)
}
```

Paper and live credentials are different — you cannot mix them.

## Rate Limits

- Basic plan: 200 requests/minute
- Unlimited: varies by account tier
- 429: respect `Retry-After` header, use exponential backoff

## Endpoint Groups

### Account

| Method | Path | Description |
|---|---|---|
| GET | `/v2/account` | Account config + status |
| GET | `/v2/account/activities` | Account activities |
| GET | `/v2/account/activities/{type}` | Activities by type |

```go
type accountResponse struct {
    ID            string `json:"id"`
    Equity        string `json:"equity"`
    Cash          string `json:"cash"`
    BuyingPower   string `json:"buying_power"`
    DayTradeCount int    `json:"daytrade_count"`
}
```

### Assets

| Method | Path | Description |
|---|---|---|
| GET | `/v2/assets` | List all tradeable assets |
| GET | `/v2/assets/{symbol_or_id}` | Get single asset |

Fields: `id`, `class` (us_equity, crypto, us_option), `exchange`, `symbol`, `status` (active, inactive), `tradable`, `marginable`, `shortable`, `easy_to_borrow`, `fractionable`.

### Orders

| Method | Path | Description |
|---|---|---|
| POST | `/v2/orders` | Submit order |
| GET | `/v2/orders` | List orders (with filters) |
| GET | `/v2/orders/{id}` | Get order by ID |
| PATCH | `/v2/orders/{id}` | Replace order |
| DELETE | `/v2/orders/{id}` | Cancel order |
| DELETE | `/v2/orders` | Cancel all orders |

**Order types:**

| Type | Description |
|---|---|
| `market` | Execute immediately at best price |
| `limit` | Execute at specified price or better |
| `stop` | Convert to market when stop price reached |
| `stop_limit` | Convert to limit order when stop price reached |
| `trailing_stop` | Stop price trails market by offset |
| `oto` | One-Triggers-Other: primary + secondary |
| `oco` | One-Cancels-Other: two orders, one fills cancels other |
| `bracket` | Take-profit + stop-loss wrapped around a primary |

**Order request:**

```go
type orderRequest struct {
    Symbol          string  `json:"symbol"`
    Side            string  `json:"side"`       // buy | sell
    Type            string  `json:"type"`       // market | limit | stop | stop_limit | trailing_stop
    Quantity        string  `json:"qty,omitempty"`
    Notional        string  `json:"notional,omitempty"` // for fractional
    LimitPrice      string  `json:"limit_price,omitempty"`
    StopPrice       string  `json:"stop_price,omitempty"`
    TimeInForce     string  `json:"time_in_force"`     // day | gtc | opg | cls | ioc | fok
    ExtendedHours   bool    `json:"extended_hours,omitempty"`
    OrderClass      string  `json:"order_class,omitempty"` // simple | bracket | oto | oco
    TakeProfit      *OrderSide  `json:"take_profit,omitempty"`
    StopLoss        *OrderSide  `json:"stop_loss,omitempty"`
}
```

**Time in Force values:**

| Value | Description |
|---|---|
| `day` | Expires at market close |
| `gtc` | Good till cancelled |
| `opg` | Use at market open |
| `cls` | Use at market close |
| `ioc` | Immediate-or-cancel |
| `fok` | Fill-or-kill |

### Positions

| Method | Path | Description |
|---|---|---|
| GET | `/v2/positions` | All open positions |
| GET | `/v2/positions/{symbol}` | Single position |
| DELETE | `/v2/positions` | Close all positions |
| DELETE | `/v2/positions/{symbol}` | Close single position |

### Crypto Trading

- Same order endpoints, but `class=crypto`
- 24/7 trading (including weekends)
- Separate crypto wallets
- Crypto-specific order types available
- See [Crypto Orders](https://docs.alpaca.markets/us/docs/crypto-orders)

### Options Trading

- Requires options account approval
- Multi-leg strategies supported (Level 3)
- Contract-specific orders with option symbols (e.g., `AAPL250620C00150000`)
- Non-trade activities for option events
- See [Options Orders](https://docs.alpaca.markets/us/docs/options-orders)

### Fractional Trading

- Market orders only
- Specify `notional` instead of `qty` (e.g., `"notional": "50.00"`)
- Available for 2,000+ US equities
- `fractionable` field on asset indicates eligibility

### Margin & Short Selling

- Up to 4x intraday, 2x overnight buying power
- PDT (Pattern Day Trader) rules apply for margin accounts under $25k
- Check `marginable`, `shortable`, `easy_to_borrow` on assets
- Intraday Margin Rule replaces PDT for non-leverage accounts

## WebSocket Streaming

```
wss://stream.data.alpaca.markets/v2/trading
```

Authentication: send auth message with `action: "auth"`, `key`, `secret`.

Channels:
- `trade_updates`: real-time order status changes
- `account_updates`: account value/cash changes

```json
{
    "action": "auth",
    "key": "{API_KEY_ID}",
    "secret": "{API_SECRET_KEY}"
}
```

## Error Handling

```go
// HTTP 422 — validation error, inspect response body for details
// HTTP 403 — trading disabled or insufficient permissions
// HTTP 429 — rate limited, use Retry-After header

func (c *Client) doWithRetry(req *http.Request) (*http.Response, error) {
    for attempt := range maxRetries {
        resp, err := c.http.Do(req)
        if err != nil {
            return nil, err
        }
        if resp.StatusCode != http.StatusTooManyRequests {
            return resp, nil
        }
        retryAfter := parseRetryAfter(resp.Header.Get("Retry-After"))
        resp.Body.Close()
        backoff := retryAfter + time.Duration(attempt)*time.Second
        time.Sleep(backoff)
    }
    return nil, fmt.Errorf("rate limited after %d retries", maxRetries)
}
```

## Testing with Paper Trading

- Use `paper-api.alpaca.markets` as base URL
- Paper accounts come pre-funded with $100k (resettable)
- Paper trading is real-time simulation with live market data
- Reset paper account via dashboard to clear positions/orders
- Paper API has the same behavior as live but no real money moves

## Existing Codebase Patterns

This project implements the Alpaca client in `internal/exchange/alpaca/alpaca.go`. Key patterns:

- `NewClientFromEnv()` reads `APCA_API_KEY_ID`, `APCA_API_SECRET_KEY`, `APCA_API_BASE_URL`, `APCA_DATA_BASE_URL` from environment
- Retry logic for 429 rate limits with exponential backoff
- HTTP client with 30s timeout
- Returns domain types from `internal/exchange` package (`exchange.Bar`, `exchange.Order`, `exchange.Account`)
