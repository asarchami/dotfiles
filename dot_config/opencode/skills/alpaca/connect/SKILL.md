---
name: alpaca-connect
description: "Alpaca Connect API for building apps that use OAuth2 to access Alpaca brokerage accounts on behalf of users. Covers app registration, the OAuth2 authorization flow, token management, scopes, and publishing to the Alpaca Connect Marketplace."
user-invocable: true
license: MIT
metadata:
  author: opencode
  version: "1.0.0"
  openclaw:
    emoji: "🔗"
    homepage: https://docs.alpaca.markets/us/docs/about-connect-api
---

**Persona:** You are a platform developer building a third-party trading application. You treat OAuth2 as the security boundary between your app and Alpaca's infrastructure. You think in terms of authorization flows, token lifecycles, and scope最小化.

**Thinking mode:** Use `ultrathink` for the OAuth2 redirect flow and token refresh logic. Shallow reasoning produces security holes and broken user onboarding.

## Overview

Alpaca Connect lets you build applications that access Alpaca brokerage accounts on behalf of users via OAuth2. Once authorized, your app can use the Trading API with the user's scoped permissions.

Two categories:
- **Broker Partners** — create their own OAuth service for end users
- **Non-Registered / Fintech Partners** — build apps on Alpaca's platform, publish to the Connect Marketplace

## Base URLs

| Environment | URL |
|---|---|
| Authorization | `https://app.alpaca.markets/oauth/authorize` |
| Token (live) | `https://api.alpaca.markets/v1/oauth/token` |
| Token (paper) | `https://paper-api.alpaca.markets/v1/oauth/token` |
| API (live) | `https://api.alpaca.markets` |
| API (paper) | `https://paper-api.alpaca.markets` |

## App Registration

1. Go to [Alpaca Dashboard → Alpaca Connect](https://app.alpaca.markets/connect)
2. Register your app with:
   - App name and description
   - Redirect URI(s)
   - Requested scopes
   - App icon and branding
3. Receive `client_id` and `client_secret`
4. For live trading, app must be approved by Alpaca Compliance

## OAuth2 Authorization Code Flow

### Step 1: Authorization Request

Redirect the user to:

```
GET https://app.alpaca.markets/oauth/authorize?response_type=code&client_id={CLIENT_ID}&redirect_uri={REDIRECT_URI}&scope={SCOPES}&state={STATE}
```

Parameters:
| Parameter | Description |
|---|---|
| `response_type` | Must be `code` |
| `client_id` | Your registered client ID |
| `redirect_uri` | Must match registered URI |
| `scope` | Comma-separated scopes (see below) |
| `state` | CSRF token (random string, verify on callback) |

### Step 2: User Authorization

User logs in to Alpaca, reviews permissions, and authorizes. Alpaca redirects back to your `redirect_uri`:

```
GET {REDIRECT_URI}?code={AUTH_CODE}&state={STATE}
```

Verify `state` matches your original value.

### Step 3: Token Exchange

Exchange the authorization code for access + refresh tokens:

```go
func exchangeCode(ctx context.Context, clientID, clientSecret, code string) (accessToken, refreshToken string, err error) {
    form := url.Values{
        "grant_type":   {"authorization_code"},
        "code":         {code},
        "client_id":    {clientID},
        "client_secret": {clientSecret},
    }
    req, _ := http.NewRequestWithContext(ctx, "POST",
        "https://api.alpaca.markets/v1/oauth/token",
        strings.NewReader(form.Encode()))
    req.Header.Set("Content-Type", "application/x-www-form-urlencoded")

    resp, err := http.DefaultClient.Do(req)
    if err != nil {
        return "", "", err
    }
    defer resp.Body.Close()

    var r struct {
        AccessToken  string `json:"access_token"`
        RefreshToken string `json:"refresh_token"`
        ExpiresIn    int    `json:"expires_in"`
    }
    if err := json.NewDecoder(resp.Body).Decode(&r); err != nil {
        return "", "", err
    }
    return r.AccessToken, r.RefreshToken, nil
}
```

### Step 4: Use Access Token

Authenticate Trading API calls with `Authorization: Bearer {ACCESS_TOKEN}` header:

```go
func setBearerAuth(req *http.Request, token string) {
    req.Header.Set("Authorization", "Bearer "+token)
}
```

### Step 5: Refresh Token

When access token expires, use the refresh token:

```go
func refreshAccessToken(ctx context.Context, clientID, clientSecret, refreshToken string) (newAccess, newRefresh string, err error) {
    form := url.Values{
        "grant_type":    {"refresh_token"},
        "refresh_token": {refreshToken},
        "client_id":     {clientID},
        "client_secret":  {clientSecret},
    }
    req, _ := http.NewRequestWithContext(ctx, "POST",
        "https://api.alpaca.markets/v1/oauth/token",
        strings.NewReader(form.Encode()))
    req.Header.Set("Content-Type", "application/x-www-form-urlencoded")

    resp, err := http.DefaultClient.Do(req)
    if err != nil {
        return "", "", err
    }
    defer resp.Body.Close()

    var r struct {
        AccessToken  string `json:"access_token"`
        RefreshToken string `json:"refresh_token"`
        ExpiresIn    int    `json:"expires_in"`
    }
    if err := json.NewDecoder(resp.Body).Decode(&r); err != nil {
        return "", "", err
    }
    return r.AccessToken, r.RefreshToken, nil
}
```

## Scopes

| Scope | Description |
|---|---|
| `account:read` | Read account info |
| `trading:read` | Read orders, positions |
| `trading:write` | Place/cancel orders |
| `data:read` | Access market data |

Choose the minimum scopes your app needs. Requesting unnecessary scopes may reduce user trust and approval rates.

## Security Best Practices

- **Never** expose client secret or access tokens publicly
- Use `state` parameter to prevent CSRF attacks
- Store tokens securely (encrypted at rest)
- Refresh tokens are long-lived; access tokens are short-lived
- Implement token rotation (new refresh token each refresh)
- Validate redirect URI matches exactly (including trailing slashes)
- Use HTTPS for all OAuth endpoints
- Alpaca supports `private_key_jwt` client authentication for additional security (client assertion signed with private key instead of shared secret)

## Testing

- Use paper trading URLs for development (`paper-api.alpaca.markets` for token + API)
- Test the full flow: authorize → code → tokens → API calls → token refresh
- Users can authorize with their paper trading account
- App must be approved by Alpaca Compliance for live trading access

## Known Limitations

- OAuth2 is only available for Trading API (not Broker API)
- Broker partners create their own OAuth service instead
- Token expiry: access tokens expire in a few hours (check `expires_in`)
- Rate limits apply per user, not per app
