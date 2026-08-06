---
name: go-grpc
description: "Go gRPC — the .proto contract defines the transport: protobuf organization, code generation, server/client implementation, interceptors, status-code error mapping, streaming, bufconn testing, TLS/mTLS. Use when implementing, reviewing, or debugging gRPC servers/clients, writing proto files, setting up interceptors, handling gRPC errors with status codes, or working with streaming RPCs."
license: MIT
---

# Go gRPC

**Leading word: contract.** The `.proto` contract is the source of truth — it defines the wire protocol and the RPCs every server and client implement. The discipline: define the contract first, treat gRPC as a pure transport layer, and keep business logic out of the transport.

## Steps — build a service

1. **Define the contract.** Organize protos by domain with versioned directories (`proto/user/v1/`). Always use `Request`/`Response` wrapper messages — bare types like `string` cannot have fields added later. Generate with `buf generate` or `protoc`.

   *Done when: every RPC uses wrapper messages, protos live in versioned domain directories, and generated code is regenerated after each change.*

2. **Serve with safety rails.** Register the health service (`grpc_health_v1`) so Kubernetes probes can determine readiness; chain interceptors for cross-cutting concerns (logging, auth, recovery) so business logic stays clean; disable reflection outside dev.

   *Done when: the server registers health, every cross-cutting concern lives in an interceptor, and reflection is off in production.*

3. **Shut down gracefully.** Use `GracefulStop()` with a timeout fallback to `Stop()` — drains in-flight RPCs while preventing hangs.

   *Done when: shutdown drains in-flight RPCs and falls back to a hard stop within a bounded timeout.*

4. **Build the client.** Reuse connections — gRPC multiplexes RPCs on one HTTP/2 connection, so one-per-request wastes TCP/TLS handshakes. Set a deadline on every call; without one a slow upstream hangs goroutines indefinitely. Use `round_robin` with headless Kubernetes services via `dns:///`, and pass metadata (auth tokens, trace IDs) via `metadata.NewOutgoingContext`.

   *Done when: the client holds one connection per target, every call has a timeout, load balancing is configured, and metadata flows with requests.*

5. **Map errors to codes.** Return `status.Errorf` with a specific code from the table below — a raw `error` becomes `codes.Unknown`, telling the client nothing actionable. Clients use codes to decide retry vs fail-fast vs degrade. Attach `errdetails.BadRequest` for field-level validation errors.

   *Done when: no handler returns a raw error where a status code fits, and field-level validation carries BadRequest details.*

6. **Pick the stream shape.** Server streaming for sequences (log tailing, result sets), client streaming for uploads/batches, bidirectional for real-time exchange. Prefer streaming over large single messages to avoid per-message size limits and lower memory pressure.

   *Done when: each RPC's stream shape matches its data flow and no message approaches the size limit.*

7. **Test against the wire.** Use `bufconn` for in-memory connections that exercise the full gRPC stack (serialization, interceptors, metadata) without network overhead, and assert the expected status code of every error scenario.

   *Done when: bufconn tests cover the happy path and every error branch returns the expected code.*

8. **Secure the transport.** Enable TLS in production — credentials travel in metadata. For service-to-service auth use mTLS or delegate to a service mesh; for user auth implement `credentials.PerRPCCredentials` and validate tokens in an auth interceptor.

   *Done when: TLS is on, and both service-to-service and user auth are enforced.*

## Steps — review or audit

1. **Read the contract first.** Wrapper messages, versioned dirs, stream shape, and generated-code freshness — check each RPC against the build steps. *Done when: every RPC has an evolvable contract and a justified stream shape.*
2. **Scan the server.** Health service, interceptors, graceful-stop fallback, reflection off in production. *Done when: the server has all four safety rails.*
3. **Scan the client.** One reused connection, deadline on every call, retry policy limited to retryable codes. *Done when: no call lacks a deadline and no connection is built per request.*
4. **Audit error codes.** Raw errors, blanket `codes.Internal`, and retryable-vs-nonretryable choices. *Done when: every error maps to a code clients can act on.*
5. **Check cancellation and security.** Long operations observe `ctx.Err()`; TLS/mTLS and reflection are configured correctly. *Done when: cancellation is respected and the transport is secured.*

## Reference

### Package and tool map

| Concern | Package / Tool |
| --- | --- |
| Service definition | `protoc` or `buf` with `.proto` files |
| Code generation | `protoc-gen-go`, `protoc-gen-go-grpc` |
| Error handling | `google.golang.org/grpc/status` with `codes` |
| Rich error details | `google.golang.org/genproto/googleapis/rpc/errdetails` |
| Interceptors | `grpc.ChainUnaryInterceptor`, `grpc.ChainStreamInterceptor` |
| Middleware ecosystem | `github.com/grpc-ecosystem/go-grpc-middleware` |
| Testing | `google.golang.org/grpc/test/bufconn` |
| TLS / mTLS | `google.golang.org/grpc/credentials` |
| Health checks | `google.golang.org/grpc/health` |

### Status codes

| Code | When to Use |
| --- | --- |
| `InvalidArgument` | Malformed input (missing field, bad format) |
| `NotFound` | Entity does not exist |
| `AlreadyExists` | Create failed, entity exists |
| `PermissionDenied` | Caller lacks permission |
| `Unauthenticated` | Missing or invalid token |
| `FailedPrecondition` | System not in required state |
| `ResourceExhausted` | Rate limit or quota exceeded |
| `Unavailable` | Transient issue, safe to retry |
| `Internal` | Unexpected bug |
| `DeadlineExceeded` | Timeout |

```go
if errors.Is(err, ErrNotFound) {
    return nil, status.Errorf(codes.NotFound, "user %q not found", req.UserId)
}
return nil, status.Errorf(codes.Internal, "lookup failed: %v", err)
```

### Streaming patterns

| Pattern | Use Case |
| --- | --- |
| Server streaming | Server sends a sequence (log tailing, result sets) |
| Client streaming | Client sends a sequence, server responds once (file upload, batch) |
| Bidirectional | Both send independently (chat, real-time sync) |

### Performance settings

| Setting | Purpose | Typical Value |
| --- | --- | --- |
| `keepalive.ServerParameters.Time` | Ping interval for idle connections | 30s |
| `keepalive.ServerParameters.Timeout` | Ping ack timeout | 10s |
| `grpc.MaxRecvMsgSize` | Override 4 MB default for large payloads | 16 MB |
| Connection pooling | Multiple conns for high-load streaming | 4 connections |

Profile before adding connection pooling — most services do not need it.

### Interceptor pattern

```go
func loggingInterceptor(ctx context.Context, req any, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (any, error) {
    start := time.Now()
    resp, err := handler(ctx, req)
    log.Printf("method=%s duration=%s code=%s", info.FullMethod, time.Since(start), status.Code(err))
    return resp, err
}
```

### Graceful shutdown

```go
go func() { srv.GracefulStop(); close(stopped) }()
select {
case <-stopped:
case <-time.After(15 * time.Second):
    srv.Stop()
}
```

### Client config

```go
conn, err := grpc.NewClient("dns:///user-service:50051",
    grpc.WithTransportCredentials(creds),
    grpc.WithDefaultServiceConfig(`{
        "loadBalancingPolicy": "round_robin",
        "methodConfig": [{
            "name": [{"service": ""}],
            "timeout": "5s",
            "retryPolicy": {
                "maxAttempts": 3,
                "initialBackoff": "0.1s",
                "maxBackoff": "1s",
                "backoffMultiplier": 2,
                "retryableStatusCodes": ["UNAVAILABLE"]
            }
        }]
    }`),
)
```

- **[Proto & code generation](./references/protoc-reference.md)** — proto layout, `buf`/`protoc` flags, codegen options
- **[Testing patterns](./references/testing.md)** — bufconn harness, status-code assertions

## Watch for

| Mistake | Fix |
| --- | --- |
| Returning raw `error` | Becomes `codes.Unknown` — client can't decide whether to retry. Use `status.Errorf` with a specific code |
| No deadline on client calls | Slow upstream hangs indefinitely. Always `context.WithTimeout` |
| New connection per request | Wastes TCP/TLS handshakes. Create once, reuse — HTTP/2 multiplexes RPCs |
| Reflection enabled in production | Lets attackers enumerate every method. Enable only in dev/staging |
| `codes.Internal` for all errors | Wrong codes break client retry logic. `Unavailable` triggers retry; `InvalidArgument` does not |
| Bare types as RPC arguments | Can't add fields to `string`. Wrapper messages allow backwards-compatible evolution |
| Missing health check service | Kubernetes can't determine readiness, kills pods during deployments |
| Ignoring context cancellation | Long operations continue after caller gave up. Check `ctx.Err()` |

## Cross-references

- → See `go-context` for deadline and cancellation patterns
- → See `go-safety` for gRPC error to Go error mapping
- → See `go-observability` for gRPC interceptors (logging, tracing, metrics)
- → See `go-testing` for gRPC testing with bufconn
