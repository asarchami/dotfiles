---
name: go-graphql
description: "Go GraphQL — design the schema first: library choice (gqlgen/graph-gophers), SDL schema design, thin resolvers, per-request DataLoaders, auth, error mapping, subscriptions, complexity limits. Apply when building GraphQL servers, designing schemas, writing resolvers, handling subscriptions, or the codebase imports `github.com/99designs/gqlgen` or `github.com/graph-gophers/graphql-go`."
license: MIT
---

# Go GraphQL

**Leading word: schema.** The schema is the product — nullability, pagination, and mutation envelopes define what clients can express. The discipline: design the schema deliberately, keep resolvers thin, and batch every child-resolver load.

## Steps — build a service

1. **Choose the library.** Both major libraries are schema-first: write SDL (`.graphql` files), bind Go resolvers. Pick gqlgen when Apollo Federation is required, the schema is large (100+ types), or you want generated stubs and zero reflection overhead. Pick graph-gophers for small/medium schemas, a simple build pipeline, or a dynamic schema. Avoid code-first `graphql-go/graphql`. See the comparison table below.

   *Done when: the library matches schema size and team needs, with a stated reason.*

2. **Design the schema deliberately.** Mark a field `!` only when the server can always return it — an error on a non-null field nulls the parent object, causing cascade failures; nullable fields only null themselves. Use the `ID` scalar for opaque identifiers, never `Int`. Use Relay cursor connections (`Connection`/`Edge`/`PageInfo`) for list fields — cursors are stable under concurrent writes.

   *Done when: every non-null field is always returnable, ids are `ID`, and every list uses cursor pagination.*

3. **Envelope your mutations.** Wrap mutation results in a payload type so clients receive business errors alongside partial results without polluting the GraphQL `errors` array: `type CreateUserPayload { user: User; errors: [UserError!]! }`.

   *Done when: every mutation returns a payload type carrying business errors.*

4. **Keep resolvers thin.** Resolvers translate GraphQL inputs to domain calls and domain responses to GraphQL outputs — no SQL, no business logic. Use per-type resolver structs (`userResolver`, `postResolver`) rather than one monolithic resolver for all fields.

   *Done when: no resolver touches a database and each type has its own resolver struct.*

5. **Batch child loads with DataLoaders.** A `User.posts` resolver fires one SQL query per parent row without batching — O(n) DB calls for n users. DataLoaders coalesce per-field loads into a single batch query. Create DataLoaders **per-request in HTTP middleware, never globally** — a global loader caches across requests, giving stale data and potential cross-user leakage. In gqlgen, mark batched fields `resolver: true` in `gqlgen.yml` to force a dedicated resolver method.

   *Done when: every child-resolver field coalesces its loads and its loader is scoped to the request.*

6. **Enforce auth in two layers.** HTTP middleware extracts and validates tokens, stashing identity in `context.Context`; per-field authorization lives in schema directives (`@hasRole`) or resolver checks — not scattered across resolvers.

   *Done when: tokens are validated once at the edge and every guarded field enforces its own policy.*

7. **Map errors for the client.** Never return raw internal errors — they leak SQL messages, stack traces, or service internals. gqlgen: a custom `ErrorPresenter` strips internal details and attaches extension codes; graph-gophers: implement the `ResolverError` interface with `Extensions()`. Use `graphql.AddError(ctx, err)` for non-fatal field errors where the resolver still returns partial data.

   *Done when: no internal detail reaches a client and every error carries a code or safe message.*

8. **Respect cancellation in subscriptions.** Subscriptions use long-lived WebSocket connections — a leaked goroutine per disconnected client exhausts resources silently. Subscribe once, `defer close(ch)`, and select on `ctx.Done()`.

   *Done when: every subscription goroutine exits on disconnect and closes its channel.*

9. **Cap query cost.** Production GraphQL servers need explicit limits — without them a single deeply nested query exhausts CPU and memory. Wire `extension.FixedComplexityLimit(200)` (gqlgen) or `graphql.MaxDepth(10)` + `graphql.MaxParallelism(10)` at `ParseSchema` time (graph-gophers). Gate introspection behind a non-production `ENV` check. In production, consider persisted queries (gqlgen APQ) to reject arbitrary query strings.

   *Done when: a complexity cap is wired, introspection is off in production, and unvetted query strings are blocked.*

## Steps — review or audit

1. **Hunt N+1.** Every child resolver that issues one query per parent row needs a per-request DataLoader. *Done when: no child field issues one query per parent row.*
2. **Check DataLoader scope.** A loader created outside request middleware is a cross-request cache. *Done when: every DataLoader is created per request.*
3. **Re-read the schema.** Nullability, `ID` ids, cursor pagination, mutation envelopes, and `models_gen.go` untouched (autobind instead). *Done when: no field breaks the nullability rule, leaks an internal id, or is edited by hand.*
4. **Verify limits and introspection.** Complexity cap present; introspection gated by environment. *Done when: a deeply nested query is capped and introspection is off in production.*
5. **Check subscriptions for leaks.** Every subscription selects on `ctx.Done()` and closes its channel. *Done when: disconnecting a client stops its goroutine.*

## Reference

### Library comparison

| Library | Approach | Type safety | Build step | Best for |
| --- | --- | --- | --- | --- |
| `github.com/99designs/gqlgen` | Codegen | Compile-time | `go generate` | Large schemas, federation, strict types |
| `github.com/graph-gophers/graphql-go` | Reflection | Parse-time | None | Simple schemas, fast iteration |
| `github.com/graphql-go/graphql` | Code-first | Runtime | None | Avoid — verbose, no SDL |

### Schema design

```graphql
# Good — explicit nullability; ID scalar for opaque identifiers
type User {
  id: ID!
  email: String! # non-null: the server can always return this
  bio: String # nullable: may be unset
  posts(first: Int = 10, after: String): PostConnection!
}

# Bad — Int ID leaks implementation details, breaks client caching
type Post {
  id: Int!
}

# Mutation envelope — business errors travel with partial results
type CreateUserPayload {
  user: User
  errors: [UserError!]!
}
```

### Per-request DataLoader

```go
func DataLoaderMiddleware(db *sql.DB, next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        loaders := &Loaders{PostsByUserID: newPostsByUserIDLoader(r.Context(), db)}
        ctx := context.WithValue(r.Context(), loadersKey, loaders)
        next.ServeHTTP(w, r.WithContext(ctx))
    })
}
```

### Error presenter (gqlgen)

```go
srv.SetErrorPresenter(func(ctx context.Context, err error) *gqlerror.Error {
    var gqlErr *gqlerror.Error
    if errors.As(err, &gqlErr) {
        return gqlErr // already formatted
    }
    // log internal err here
    return gqlerror.Errorf("internal error") // safe client message
})
```

### Limits and introspection

```go
srv := handler.NewDefaultServer(es)
srv.Use(extension.FixedComplexityLimit(200)) // max cost per query
if os.Getenv("ENV") != "production" {
    srv.Use(extension.Introspection{})
}
```

### Subscription lifecycle

```go
func (r *subscriptionResolver) MessageAdded(ctx context.Context, room string) (<-chan *model.Message, error) {
    ch := make(chan *model.Message, 1)
    sub := r.pubsub.Subscribe(room) // subscribe once before the goroutine
    go func() {
        defer close(ch) // always close; signals iteration to stop
        for {
            select {
            case <-ctx.Done():
                return // client disconnected
            case msg := <-sub:
                ch <- msg
            }
        }
    }()
    return ch, nil
}
```

- **[gqlgen reference](./references/gqlgen.md)** — codegen workflow, `gqlgen.yml`, DataLoaders, Federation v2, directives
- **[graphql-go reference](./references/graphql-go.md)** — reflection resolver model, type mapping, tracing
- **[Testing](./references/testing.md)** — gqlgen client harness, gqltesting, httptest patterns

## Watch for

| Mistake | Fix |
| --- | --- |
| N+1 queries in child resolvers | One SQL per parent row → O(n) DB calls. Use per-request DataLoader |
| Global DataLoader | Cross-request cache — stale data, data leaks. Create DataLoader in request middleware |
| Editing `models_gen.go` directly | Next `go generate` wipes hand edits. Use `autobind` or `models.<T>.model` in `gqlgen.yml` |
| Forgetting `go generate` after schema change | Resolver interface mismatch at compile time. Re-run `go run github.com/99designs/gqlgen generate` |
| `int` field in graph-gophers resolver | Library requires `int32` for `Int` scalar. Use `int32` (or `float64` for `Float`) |
| Introspection enabled in production | Exposes full schema to attackers. Gate with `ENV` check |
| No complexity cap | Deeply nested query → CPU/memory DoS. `extension.FixedComplexityLimit(N)` |
| Leaking DB errors from resolvers | Exposes SQL internals to clients. Wrap in `ErrorPresenter` / `ResolverError` |
| Subscription goroutine leak | Client disconnect → goroutine runs forever. `defer close(ch)` + `select ctx.Done()` |
| Nullable field for always-required data | Clients must null-check everywhere. Mark `!` in schema; return error from resolver |

## Cross-references

- → See `go-context` for context propagation in resolvers and subscriptions
- → See `go-safety` for error wrapping and sentinel patterns
- → See `go-testing` for table-driven and integration test patterns
- → See `go-observability` for tracing and metrics in resolvers
- → See `go-security` for input validation and injection prevention
- → See `go-database` for N+1 query patterns and DataLoader database batching
