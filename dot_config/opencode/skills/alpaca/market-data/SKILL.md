---
name: alpaca-market-data
description: "Alpaca Market Data API for historical and real-time market data. Covers stocks, crypto, options, and news — both REST (historical bars/quotes/trades) and WebSocket (real-time streaming). Includes subscription plans, rate limits, and authentication patterns for Trading API and Broker API users."
user-invocable: true
license: MIT
metadata:
  author: opencode
  version: "1.0.0"
  openclaw:
    emoji: "📊"
    homepage: https://docs.alpaca.markets/us/docs/about-market-data-api
---

**Persona:** You are a quantitative developer building data pipelines. You treat market data as the foundation for trading decisions and backtesting. You think in terms of data completeness, latency, and alignment across timeframes.

**Thinking mode:** Use `ultrathink` for historical data pagination, WebSocket reconnection logic, and data alignment across multiple symbols. Shallow reasoning produces gaps and misaligned time series.

## Base URLs

| Environment | URL |
|---|---|
| Live | `https://data.alpaca.markets` |
| Sandbox (Broker API) | `https://data.sandbox.alpaca.markets` |

## Authentication

**Trading API users** (legacy auth):
```go
req.Header.Set("APCA-API-KEY-ID", apiKeyID)
req.Header.Set("APCA-API-SECRET-KEY", apiSecret)
```

**Broker API users** (OAuth2 Client Credentials):
```go
req.Header.Set("Authorization", "Bearer {TOKEN}")
```

Historical crypto data does **not** require authentication.

## Subscription Plans

### Trading API

| Feature | Basic (free) | Algo Trader Plus ($99/mo) |
|---|---|---|
| Stocks coverage | IEX only | All US exchanges |
| WebSocket symbols | 30 | Unlimited |
| Historical window | Since 2016 | Since 2016 |
| Historical limit | Last 15 min | No restriction |
| API calls | 200/min | 10,000/min |
| Options coverage | Indicative feed | OPRA feed |

### Broker API

| Plan | RPM | Stream connections | Stream symbols | Price |
|---|---|---|---|---|
| Standard | 1,000 | 5 | unlimited | included |
| StandardPlus3000 | 3,000 | 5 | unlimited | $500/mo |
| StandardPlus5000 | 5,000 | 5 | unlimited | $1,000/mo |
| StandardPlus10000 | 10,000 | 10 | unlimited | $2,000/mo |

## Historical API (REST)

### Stock Data

```
GET /v2/stocks/{symbol}/bars
GET /v2/stocks/{symbol}/quotes
GET /v2/stocks/{symbol}/trades
GET /v2/stocks/bars      (multi-symbol)
```

Query parameters: `timeframe` (1Min, 5Min, 15Min, 1Hour, 1Day), `start`, `end`, `limit` (max 10,000), `adjustment` (raw, split, dividend), `feed` (iex, sip).

```go
func (c *Client) Bars(ctx context.Context, symbol string, start, end time.Time, interval string) ([]exchange.Bar, error) {
    u, _ := url.JoinPath(c.dataBaseURL, "/v2/stocks", symbol, "bars")

    req, _ := http.NewRequestWithContext(ctx, http.MethodGet, u, nil)
    q := req.URL.Query()
    q.Set("timeframe", interval)
    q.Set("start", start.Format(time.RFC3339))
    q.Set("end", end.Format(time.RFC3339))
    req.URL.RawQuery = q.Encode()

    c.setAuthHeaders(req)
    resp, err := c.doWithRetry(req)
    // ... parse response
}
```

**Pagination:** When response contains `next_page_token`, repeat the request with `page_token={token}` until no token returned.

### Crypto Data

```
GET /v2/crypto/{symbol}/bars
GET /v2/crypto/{symbol}/quotes
GET /v2/crypto/{symbol}/trades
```

Same parameters as stocks. Crypto data does not require authentication for historical endpoints. Timeframes: 1Min, 5Min, 15Min, 1Hour, 1Day.

### Options Data

```
GET /v2/options/{symbol}/bars
GET /v2/options/{symbol}/quotes
GET /v2/options/{symbol}/snapshots
```

Option symbols use the OCC format (e.g., `AAPL250620C00150000`). Requires options data subscription.

### News Data

```
GET /v1beta1/news
```

Parameters: `symbols`, `start`, `end`, `limit`, `sort`, `include_content`.

## WebSocket Streams

```
wss://stream.data.alpaca.markets/v2/{feed}
```

Feeds:
- `iex` — IEX data only (free)
- `sip` — SIP data (all exchanges, paid)

### Authentication Message

```json
{"action": "auth", "key": "{KEY}", "secret": "{SECRET}"}
```

### Stock Channels

| Channel | Description |
|---|---|
| `T` | Trades |
| `Q` | Quotes |
| `AM` | Minute bars (aggregated) |
| `A` | Second bars (aggregated) |

### Crypto Channels

| Channel | Description |
|---|---|
| `T.{symbol}` | Trades |
| `Q.{symbol}` | Quotes |
| `AM.{symbol}` | Minute bars |

### Options Channels

| Channel | Description |
|---|---|
| `O.{symbol}` | Options trades |
| `OQ.{symbol}` | Options quotes |

### News Channel

| Channel | Description |
|---|---|
| `news` | Real-time news headlines |

### Subscription Message

```json
{"action": "subscribe", "trades": ["AAPL", "SPY"], "quotes": ["TSLA"]}
```

### Reconnection

- WebSocket sends `: you are reading too slowly, dropped N messages` as SSE-style comment when client falls behind
- On disconnect: reconnect and re-auth, then resubscribe to channels
- Missed data can be backfilled via Historical API

## Rate Limits

| Plan | Historical API limit |
|---|---|
| Trading API Basic | 200 RPM |
| Trading API Algo Trader+ | 10,000 RPM |
| Broker API Standard | 1,000 RPM |
| Broker API higher tiers | 3,000–10,000 RPM |

429 responses include `Retry-After` header.

## Existing Codebase Patterns

This project fetches market data in `internal/bars/service.go` using the Alpaca client from `internal/exchange/alpaca/alpaca.go`. Key pattern:

```go
bars, err := s.barReader.Bars(ctx, sym.Symbol, start, now, "5m")
```

The exchange interface (`internal/exchange/exchange.go`) defines:

```go
type Exchange interface {
    Bars(ctx context.Context, symbol string, start, end time.Time, interval string) ([]Bar, error)
    SubmitOrder(ctx context.Context, order Order) (string, error)
    Account(ctx context.Context) (Account, error)
}
```
