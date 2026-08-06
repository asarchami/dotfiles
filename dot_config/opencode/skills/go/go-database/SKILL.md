---
name: go-database
description: "Go database access — explicit SQL with database/sql, sqlx, pgx: parameterized queries, struct scanning, NULLable column handling, error patterns, transactions, isolation levels, SELECT FOR UPDATE, connection pool, context propagation, batch processing, migrations. Use when writing or reviewing Go code that touches PostgreSQL, MariaDB, MySQL, or SQLite, debugging query or connection issues, or testing database code. Does not cover schema creation or migration SQL."
license: MIT
---

# Go Database

**Leading word: explicit.** Keep every interaction with the database explicit: SQL you can see and version-control, queries **parameterized** against injection, errors you handle at the boundary, connections you close, transactions you bound, and a pool you configure. When SQL is invisible (ORMs) or resources are implicit, integrity bugs hide until production.

## Steps — write database code

1. **Choose the access layer.** `database/sql` for portability and minimal deps, `sqlx` for multi-database struct scanning, `pgx` for PostgreSQL (faster, COPY, LISTEN, arrays). Skip ORMs — they hide query generation and leak the abstraction.

   *Done when: the chosen layer matches the database and the scanning needs, and the SQL stays visible in code.*

2. **Parameterize every query.** Use driver placeholders (`$1` for PostgreSQL, `?` for MySQL) — never interpolate user input into a SQL string. For dynamic `IN` clauses use `sqlx.In` + `Rebind`; for dynamic column names use an allowlist map.

   *Done when: no SQL string on the path contains concatenated or `fmt.Sprintf`-injected values.*

3. **Propagate context.** Use the `*Context` variants (`QueryContext`, `ExecContext`, `GetContext`) everywhere so cancellation and deadlines reach the driver.

   *Done when: every database call in the call path receives the caller's context.*

4. **Handle errors explicitly.** Distinguish "not found" from real failures with `errors.Is(err, sql.ErrNoRows)` and translate to a domain error; wrap unexpected errors with `fmt.Errorf("...: %w", err)`.

   *Done when: no `ErrNoRows` reaches a caller as a raw technical error, and every real error carries context.*

5. **Manage resources.** `defer rows.Close()` immediately after `QueryContext`; check `rows.Err()` after iteration; use `db.Exec` for statements that return no rows (`Query` returns a `*Rows` you must close or the connection leaks).

   *Done when: every `Rows` is closed and drained, and no `Query` call exists for a row-less statement.*

6. **Configure the pool.** Set `SetMaxOpenConns`, `SetMaxIdleConns`, `SetConnMaxLifetime`, and `SetConnMaxIdleTime` at startup.

   *Done when: all four pool knobs are set with values derived from the workload, not left at defaults.*

7. **Bound multi-statement work in transactions.** Wrap related writes in `BeginTx` with `defer` Rollback-on-error; use `SELECT ... FOR UPDATE` when reading data you intend to modify; raise the isolation level (e.g. serializable) when READ COMMITTED is insufficient.

   *Done when: every group of related writes runs atomically, and read-then-modify paths are locked against concurrent writers.*

8. **Batch in reasonable sizes.** Not row-by-row (round trips) and not millions at once (locks, memory).

   *Done when: batch size balances round trips against lock hold time for the workload.*

## Steps — review or debug existing code

1. **Scan for string-built SQL** — concatenation, `fmt.Sprintf`, interpolated column names. *Done when: every query is parameterized or allowlisted.*
2. **Check resource closure** — every `QueryContext` has `defer rows.Close()`; no `db.Query` for `Exec`-style statements. *Done when: no Rows leaks a connection back to the pool.*
3. **Check context propagation** — no non-`*Context` call on a request path. *Done when: every call receives the request's context.*
4. **Check error handling** — `ErrNoRows` translated, errors wrapped, `rows.Err()` checked. *Done when: every failure path distinguishes not-found from error and carries context.*
5. **Check transactions and the pool** — write groups atomic, locking matches the read-modify pattern, pool configured. *Done when: no implicit multi-statement write or default pool settings remain.*
6. **Check for hidden SQL** — no reliance on triggers, views, materialized views, stored procedures, or row-level security from application code. *Done when: all SQL behavior is explicit and visible in Go.*

## Reference

### Library choice

| Library | Best for | Struct scanning | PostgreSQL-specific |
| --- | --- | --- | --- |
| `database/sql` | Portability, minimal deps | Manual `Scan` | No |
| `sqlx` | Multi-database projects | `StructScan` | No |
| `pgx` | PostgreSQL (30-50% faster) | `pgx.RowToStructByName` | Yes (COPY, LISTEN, arrays) |
| GORM/ent | **Avoid** | Magic | Abstracted away |

### Parameterized queries

```go
// PostgreSQL
err := db.GetContext(ctx, &user, "SELECT id, name, email FROM users WHERE email = $1", email)

// MySQL
err := db.GetContext(ctx, &user, "SELECT id, name, email FROM users WHERE email = ?", email)

// Dynamic IN clause
query, args, err := sqlx.In("SELECT * FROM users WHERE id IN (?)", ids)
if err != nil { return fmt.Errorf("building IN clause: %w", err) }
query = db.Rebind(query) // adjust placeholders for your driver
err = db.SelectContext(ctx, &users, query, args...)

// Dynamic column name — never from user input; allowlist first
allowed := map[string]bool{"name": true, "email": true, "created_at": true}
if !allowed[sortCol] { return fmt.Errorf("invalid sort column: %s", sortCol) }
query := fmt.Sprintf("SELECT id, name, email FROM users ORDER BY %s", sortCol)
```

### Error handling

```go
func GetUser(id string) (*User, error) {
    var user User
    err := db.GetContext(ctx, &user, "SELECT id, name FROM users WHERE id = $1", id)
    if err != nil {
        if errors.Is(err, sql.ErrNoRows) {
            return nil, ErrUserNotFound // translate to a domain error
        }
        return nil, fmt.Errorf("querying user %s: %w", id, err)
    }
    return &user, nil
}
```

Alternative signature: `(u *User, exists bool, err error)` where "no user" returns `(nil, false, nil)`.

### Always close rows

```go
rows, err := db.QueryContext(ctx, "SELECT id, name FROM users")
if err != nil {
    return fmt.Errorf("querying users: %w", err)
}
defer rows.Close() // prevents connection leaks

for rows.Next() {
    // ...
}
if err := rows.Err(); err != nil { // always check after iteration
    return fmt.Errorf("iterating users: %w", err)
}
```

### Common database error patterns

| Error | How to detect | Action |
| --- | --- | --- |
| Row not found | `errors.Is(err, sql.ErrNoRows)` | Return a domain error |
| Unique constraint | Driver-specific error code | Return a conflict error |
| Connection refused | `err != nil` on `db.PingContext` | Fail fast, log, retry with backoff |
| Serialization failure | PostgreSQL code `40001` | Retry the entire transaction |
| Context canceled | `errors.Is(err, context.Canceled)` | Stop processing, propagate |

### Connection pool

```go
db.SetMaxOpenConns(25)                     // limit total connections
db.SetMaxIdleConns(10)                     // keep warm connections ready
db.SetConnMaxLifetime(5 * time.Minute)     // recycle stale connections
db.SetConnMaxIdleTime(1 * time.Minute)     // close idle connections faster
```

For sizing formulas and batch/query optimization, see [Database Performance](./references/performance.md).

### Migrations

Use an external tool — [golang-migrate](https://github.com/golang-migrate/migrate), [Flyway](https://flywaydb.org/), or [Atlas](https://atlasgo.io/). Migration SQL is written and reviewed by humans, versioned in source control, and applied through CI/CD. This skill does not generate schemas or migration SQL: schema design needs data volumes, access patterns, and production constraints that toy data cannot reveal.

### Struct scanning and NULLable columns

Use `db:"column_name"` tags for sqlx, `pgx.CollectRows` with `pgx.RowToStructByName` for pgx. Handle NULLable columns with pointer fields (`*string`, `*time.Time`) — they work cleanly with both scanning and JSON marshaling. See [Scanning Reference](./references/scanning.md) for all approaches.

### Deep dives

- [Transactions](./references/transactions.md) — transaction boundaries, isolation levels, deadlock prevention, `SELECT FOR UPDATE`
- [Testing Database Code](./references/testing.md) — mock connections, integration tests with containers, fixtures, schema setup/teardown
- [Database Performance](./references/performance.md) — pool sizing, batch processing, indexing strategy, query optimization
- [Struct Scanning](./references/scanning.md) — struct tags, NULLable handling, JSON marshaling

### External references

- [database/sql tutorial](https://go.dev/doc/database/)
- [sqlx](https://github.com/jmoiron/sqlx)
- [pgx](https://github.com/jackc/pgx)
- [golang-migrate](https://github.com/golang-migrate/migrate)

## Watch for

| Mistake | Fix |
| --- | --- |
| String-concatenated SQL (injection) | Parameterized placeholders for every value |
| Interpolated column names from user input | Allowlist + map lookup |
| `db.Query` for statements with no rows | `db.Exec` — avoids an unclosed `*Rows` |
| Missing `rows.Close()` | `defer rows.Close()` right after `QueryContext` |
| `sql.ErrNoRows` treated as a fatal error | `errors.Is` → domain error |
| No `*Context` variants on a request path | Propagate the caller's context |
| ORM magic hiding queries | Explicit SQL with sqlx or pgx |
| Row-by-row inserts | Batch in reasonable sizes |
| Default pool settings | Configure all four pool knobs |
| Related writes without a transaction | `BeginTx` + deferred commit/rollback |
| Hidden SQL features (triggers, views, stored procs) | Keep SQL explicit and visible in Go |

## Cross-references

- → See `go-security` for SQL injection prevention patterns
- → See `go-context` for context propagation to database operations
- → See `go-safety` for database error wrapping patterns
- → See `go-testing` for database integration test patterns
