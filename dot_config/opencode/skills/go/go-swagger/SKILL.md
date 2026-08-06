---
name: go-swagger
description: "swag OpenAPI documentation — annotation contract for Go APIs: @Summary/@Param/@Success/@Router/@Security, swag init generation, framework wiring, security definitions, and struct tags. Use when adding Swagger to a Go project, annotating handlers, generating docs, or auditing existing annotations for completeness and correctness."
license: MIT
---

# Go Swagger

**Leading word: document.** Docs are a contract — the Swagger UI is the source of truth for API consumers, so every annotation must match the code it describes. The discipline: annotate every handler completely, regenerate `docs/` after every change, and keep the general info, security definitions, and struct tags consistent so generation never silently drops them.

## Steps — build swagger docs

1. **Install and generate the baseline.** Run `swag init` (with `-g cmd/api/main.go` when general info isn't in `main.go`), then `swag fmt` to format annotation comments.
   *Done when: `docs/` contains `docs.go`, `swagger.json`, and `swagger.yaml` and `swag fmt` reports nothing.*

2. **Define general API info in `main.go`.** Set `@title`, `@version`, `@description`, `@host`, `@BasePath`, `@schemes`, contact, and license — and declare every security scheme here once (`@securityDefinitions.apikey`, `.basic`, `.oauth2.authorizationCode`).
   *Done when: the spec carries a title, version, host, base path, and all security definitions before any endpoint is annotated.*

3. **Annotate each handler.** Put the standard godoc line (`// ShowAccount godoc`) first — it anchors indentation for `swag fmt` — then `@Summary`, `@Description`, `@Tags`, `@Accept`, `@Produce`, `@Param` per input, `@Success`/`@Failure` per response, `@Router`, and `@Security`.
   *Done when: every exposed endpoint has a `@Summary`, a `@Router`, a `@Param` for each input, and a `@Success` with the right kind.*

4. **Use structs for `body` params and response models.** `@Param body` and `@Success {object}` need named structs; a primitive or `map[string]any` cannot derive a schema. Quote multi-word tags: `@Tags "user accounts"`.
   *Done when: no body param or response object references a primitive, a map, or an anonymous type.*

5. **Apply `@Security` to every protected route.** Reference the definitions declared in step 2 (`@Security Bearer`, `@Security OAuth2[read, write]`, `@Security BasicAuth && ApiKeyAuth`).
   *Done when: every authenticated endpoint carries a `@Security` line and the UI shows the lock icon.*

6. **Enrich models with struct tags.** `example`, `enums`, `minimum`/`maximum`, `minLength`/`maxLength`, `swaggertype` for type overrides (`time.Time` → `"primitive,integer"`), `format:"base64"`, `swaggerignore:"true"` for secrets, `extensions:"x-nullable"`.
   *Done when: every field whose generated schema would be wrong or misleading carries the fixing tag.*

7. **Wire the UI endpoint.** Blank-import `docs` to register the spec; use a named import when overriding `docs.SwaggerInfo.Host` / `BasePath` at runtime for multi-environment deploys.
   *Done when: `/swagger/index.html` loads the live spec for the chosen framework.*

8. **Regenerate after every annotation change.** `swag init` and commit `docs/` so consumers never get a stale schema.
   *Done when: committed `swagger.json` matches the current code on the same commit.*

## Steps — audit annotations

1. **Check `@Param` correctness.** `<in>` is right for each input (`path` for segments, `query` for search, `body` as a struct, `header`, `formData`), `required` is truthful, and attributes (`minimum`, `Enums`, `example`, …) match the code. *Done when: no `body` param uses a primitive and no input is undocumented.*
2. **Check response kinds.** `{object}` for single structs, `{array}` for slices, `string`/`integer` for primitives; no map or anonymous type without a named struct. *Done when: every `@Success`/`@Failure` kind derives from a named type.*
3. **Check security coverage.** Every authenticated endpoint has `@Security`; no protected route shows an open lock in the UI. *Done when: security coverage matches the router's middleware.*
4. **Check the general info location.** `@title`/`@host`/`@BasePath` live in the file passed via `-g`; otherwise swag silently skips them. *Done when: the generated spec has title, host, and base path set.*
5. **Re-run generation and diff.** *Done when: regenerated docs are identical to the committed ones.*

## Reference

### Setup commands

```bash
swag init                        # generates docs/ with docs.go, swagger.json, swagger.yaml
swag init -g cmd/api/main.go     # when general info is not in main.go
swag fmt                         # format annotation comments (like go fmt)
```

```go
import _ "yourmodule/docs"     // blank: registers spec, no identifier
import docs "yourmodule/docs"  // named: use when overriding SwaggerInfo
```

### Framework wiring

```go
// Gin
r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))
// Echo
e.GET("/swagger/*", echoSwagger.WrapHandler)
// Fiber
app.Get("/swagger/*", fiberSwagger.WrapHandler(swaggerFiles.Handler))
// net/http / Chi
mux.Handle("/swagger/", httpSwagger.Handler(swaggerFiles.Handler))
```

Dynamic host/basepath:

```go
docs.SwaggerInfo.Host     = os.Getenv("API_HOST")
docs.SwaggerInfo.BasePath = "/api/v1"
```

### General API info

```go
// @title           My API
// @version         1.0
// @description     Short description of the API.
// @host            localhost:8080
// @BasePath        /api/v1
// @schemes         http https

// @contact.name    API Support
// @contact.email   support@example.com
// @license.name    Apache 2.0

// @securityDefinitions.apikey Bearer
// @in header
// @name Authorization
// @description Type "Bearer" followed by a space and the JWT token.
```

### Operation annotations

```go
// ShowAccount godoc
// @Summary      Get account by ID
// @Description  Returns account details for the given ID.
// @Tags         accounts
// @Accept       json
// @Produce      json
// @Param        id      path  int  true  "Account ID"
// @Param        filter  query string false "Optional search filter"
// @Success      200  {object}  model.Account
// @Success      204  "No content"
// @Failure      400  {object}  api.ErrorResponse
// @Failure      404  {object}  api.ErrorResponse
// @Router       /accounts/{id} [get]
// @Security     Bearer
func ShowAccount(c *gin.Context) {}
```

`@Param <name> <in> <type> <required> "<description>" [attributes]` — attributes include `default(v)`, `minimum(n)`, `maximum(n)`, `minLength(n)`, `maxLength(n)`, `Enums(a,b,c)`, `example(v)`, `collectionFormat(multi)`.

| `<in>` | Usage |
| --- | --- |
| `path` | URL path segment (`/users/{id}`) |
| `query` | URL query string (`?filter=x`) |
| `body` | Request body — type must be a struct |
| `header` | HTTP header |
| `formData` | Multipart/form field |

`@Success <code> {<kind>} <type> "<description>"` — `{object}` single struct, `{array}` slice of structs, `string`/`integer` primitive. Generics (swag v2): `@Success 200 {object} api.Response[model.User]`. Nested composition: `@Success 200 {object} api.Response{data=model.User}`.

### Security definitions

```go
// Bearer / JWT
// @securityDefinitions.apikey Bearer
// @in header
// @name Authorization

// API key in header
// @securityDefinitions.apikey ApiKeyAuth
// @in header
// @name X-API-Key

// Basic auth
// @securityDefinitions.basic BasicAuth

// OAuth2 authorization code
// @securityDefinitions.oauth2.authorizationCode OAuth2
// @authorizationUrl https://example.com/oauth/authorize
// @tokenUrl https://example.com/oauth/token
// @scope.read Read access
// @scope.write Write access
```

Apply per endpoint: `@Security Bearer` · `@Security OAuth2[read, write]` · `@Security BasicAuth && ApiKeyAuth` (AND — both required).

### Struct tags

```go
type CreateUserRequest struct {
    Name   string `json:"name" example:"Jane Doe" minLength:"2" maxLength:"100"`
    Role   string `json:"role" enums:"admin,user,guest" example:"user"`
    Age    int    `json:"age" minimum:"18" maximum:"120"`
    Avatar []byte `json:"avatar" swaggertype:"string" format:"base64"`
    Secret string `json:"-" swaggerignore:"true"`  // excluded from docs
}
```

| Tag | Purpose |
| --- | --- |
| `example` | Example value shown in Swagger UI |
| `enums` | Comma-separated allowed values |
| `swaggertype` | Override detected type (e.g., `"primitive,integer"` for `time.Time`) |
| `swaggerignore:"true"` | Exclude field from the generated schema |
| `extensions` | OpenAPI extensions: `extensions:"x-nullable,x-deprecated=true"` |

### CLI reference

- **[swag-cli.md](./references/swag-cli.md)** — full `swag` command-line reference

## Watch for

| Mistake | Fix |
| --- | --- |
| Missing `_ "yourmodule/docs"` import | Add the blank import in main.go or server init — the UI loads empty otherwise |
| Stale `docs/` after code changes | Re-run `swag init` after every annotation change |
| `@Param body` with a primitive type | Use a named struct for body params |
| No `@Security` on protected routes | Apply `@Security` to every authenticated endpoint |
| General info annotations in the wrong file | Use `-g <file>` or move them to `main.go` — swag silently skips them otherwise |
| `{object}` with a map type | Use a named struct or annotate with `swaggertype` |
| Multi-word `@Tags` without quotes | Quote tags with spaces: `@Tags "user accounts"` |

## Cross-references

- → See `go-security` for securing the Swagger UI endpoint in production (disable or gate with auth middleware)
- → See `go-grpc` for gRPC — use grpc-gateway with its own OpenAPI generator instead of swag
