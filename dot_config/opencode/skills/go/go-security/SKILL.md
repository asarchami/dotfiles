---
name: go-security
description: "Go security — map trust boundaries before writing or reviewing code: injection, cryptography, secrets, web headers, cookies, filesystem, memory safety, logging. Use when auditing a PR for vulnerabilities, running a full codebase security scan, or writing code that touches untrusted input, crypto, secrets, auth, or I/O."
license: MIT
---

# Go Security

**Leading word: trust.** Security in Go starts by mapping the **trust** boundaries — where untrusted data enters, what an attacker controls, and the blast radius if a defense fails. The discipline: trace the data flow to its origin before flagging, and defend at every layer (defense in depth), never relying on a single upstream check.

## Steps — review

1. **Trace the data flow, not the snippet.** Follow the variable to its origin (user input, hardcoded constant, internal-only value), check for upstream validation, examine the trust boundary it crosses, and read the surrounding middleware/wrappers.

   *Done when: every flagged line is traced to its origin and the boundary it crosses.*

2. **Adjust severity, don't dismiss.** Upstream protection changes severity — a SQL concat reachable only through a strict parser is medium, not critical — but every layer must still protect itself. Document downgrades with an inline `// security:` comment so future audits don't re-flag.

   *Done when: each finding is scored with adjusted severity, noting upstream defenses and what happens if they're removed.*

3. **Walk the vulnerability table.** Check each applicable row of the quick reference below (SQL, command injection, XSS, path traversal, timing, crypto, headers, rate limiting, races) against the changed lines.

   *Done when: every applicable row of the table is checked against the diff.*

4. **Score with DREAD, report by severity.** Rank Critical/High/Medium/Low; Critical (8-10) demands immediate action.

   *Done when: findings are ranked with DREAD scores and Critical findings are queued for immediate fix.*

## Steps — audit

1. **Fan out by domain.** Run one pass per vulnerability domain — injection, cryptography and secrets, web security and headers, auth and authorization, concurrency and dependencies — and aggregate the findings.

   *Done when: every domain is covered and findings are merged into one list.*

2. **Score and report.** Apply the severity table and DREAD scoring; report by severity with the trust boundary each finding crosses.

   *Done when: a severity-ranked report names the boundary and data flow behind each finding.*

## Steps — write

1. **Map the boundary first.** Before writing, ask: where does untrusted data enter, what can an attacker control, and what is the blast radius?

   *Done when: every new input path names its trust boundary and the defense at it.*

2. **Use the safe default per category.** Parameterized queries, `exec.Command` with separate args, `html/template` auto-escaping, `os.Root`/`filepath.Clean`, `crypto/rand`, `crypto/subtle.ConstantTimeCompare`, AES-GCM, Argon2id/bcrypt — matching the quick reference below.

   *Done when: each risky operation uses the standard-library solution listed in the table.*

3. **Guard secrets and errors.** No hardcoded secrets (env vars or secret managers); return generic messages to clients and log details server-side.

   *Done when: no secret is in source and no stack trace or DB error reaches the client.*

4. **Verify with tooling.** Run `gosec ./...`, `govulncheck ./...`, `go test -race ./...`, and fuzz where input parsing is involved.

   *Done when: gosec and govulncheck are clean and the race detector is green.*

## Reference

### Vulnerability quick reference

| Severity | Vulnerability | Defense | Standard Library Solution |
| --- | --- | --- | --- |
| Critical | SQL Injection | Parameterized queries separate data from code | `database/sql` with `?` placeholders |
| Critical | Command Injection | Pass args separately, never via shell concatenation | `exec.Command` with separate args |
| High | XSS | Auto-escaping renders user data as text, not HTML/JS | `html/template`, `text/template` |
| High | Path Traversal | Scope file access to a root, prevent `../` escapes | `os.Root` (Go 1.24+), `filepath.Clean` |
| Medium | Timing Attacks | Constant-time comparison avoids byte-by-byte leaks | `crypto/subtle.ConstantTimeCompare` |
| High | Crypto Issues | Use vetted algorithms; never roll your own | `crypto/aes`, `crypto/rand` |
| Medium | HTTP Security | TLS + security headers prevent downgrade attacks | `net/http`, configure TLSConfig |
| Low | Missing Headers | HSTS, CSP, X-Frame-Options prevent browser attacks | Security headers middleware |
| Medium | Rate Limiting | Rate limits prevent brute-force and resource exhaustion | `golang.org/x/time/rate`, server timeouts |
| High | Race Conditions | Protect shared state to prevent data corruption | `sync.Mutex`, channels, avoid shared state |

### Severity levels (DREAD)

| Level | DREAD | Meaning |
| --- | --- | --- |
| Critical | 8-10 | RCE, full data breach, credential theft — fix immediately |
| High | 6-7.9 | Auth bypass, significant data exposure, broken crypto — fix in current sprint |
| Medium | 4-5.9 | Limited exposure, session issues, defense weakening — fix in next sprint |
| Low | 1-3.9 | Minor info disclosure, best-practice deviations — fix opportunistically |

### Tooling

```bash
go install github.com/securego/gosec/v2/cmd/gosec@latest
gosec ./...
go install golang.org/x/vuln/cmd/govulncheck@latest
govulncheck ./...
go test -race ./...
go test -fuzz=Fuzz
```

### Anti-patterns

| Severity | Anti-Pattern | Why It Fails | Fix |
| --- | --- | --- | --- |
| High | Security through obscurity | Hidden URLs are discoverable via fuzzing, logs, or source | Authentication + authorization on all endpoints |
| High | Trusting client headers | `X-Forwarded-For`, `X-Is-Admin` are trivially forged | Server-side identity verification |
| High | Client-side authorization | JavaScript checks are bypassed by any HTTP client | Server-side permission checks on every handler |
| High | Shared secrets across envs | Staging breach compromises production | Per-environment secrets via secret manager |
| Critical | Ignoring crypto errors | `_, _ = encrypt(data)` silently proceeds unencrypted | Always check errors — fail closed, never open |
| Critical | Rolling your own crypto | Custom encryption hasn't been analyzed by cryptographers | Use `crypto/aes` GCM, `golang.org/x/crypto/argon2` |

### Deep dives

- [Cryptography](./references/cryptography.md) — algorithms, key derivation, TLS
- [Injection Vulnerabilities](./references/injection.md) — SQL, command, template, XSS, SSRF
- [Filesystem Security](./references/filesystem.md) — path traversal, zip bombs, permissions, symlinks
- [Network/Web Security](./references/network.md) — SSRF, redirects, headers, timing, session fixation
- [Cookie Security](./references/cookies.md) — Secure, HttpOnly, SameSite flags
- [Third-Party Data Leaks](./references/third-party.md) — analytics privacy, GDPR/CCPA
- [Memory Safety](./references/memory-safety.md) — integer overflow, aliasing, `unsafe`
- [Secrets Management](./references/secrets.md) — hardcoded credentials, env vars, secret managers
- [Logging Security](./references/logging.md) — PII in logs, log injection, sanitization
- [Threat Modeling](./references/threat-modeling.md) — STRIDE, DREAD, trust boundaries, OWASP Top 10
- [Security Architecture](./references/architecture.md) — defense-in-depth, Zero Trust, auth, rate limiting
- [Review Checklist](./references/checklist.md) — domain-organized review checklist

## Watch for

| Mistake | Fix |
| --- | --- |
| `math/rand` for tokens (High) | `crypto/rand` — output must be unpredictable |
| SQL string concatenation (Critical) | Parameterized queries keep data and code separate |
| `exec.Command("bash -c")` (Critical) | Pass args separately to avoid shell parsing |
| Trusting unsanitized input (High) | Validate at trust boundaries |
| Hardcoded secrets (Critical) | Env vars or secret managers |
| Comparing secrets with `==` (Medium) | `crypto/subtle.ConstantTimeCompare` |
| Returning detailed errors (Medium) | Generic messages to clients; details logged server-side |
| Ignoring `-race` findings (High) | Fix all races — they can bypass auth under concurrency |
| MD5/SHA1 for passwords (High) | Argon2id or bcrypt — slow, memory-hard |
| AES without GCM (High) | GCM provides encrypt + authenticate |
| Binding to 0.0.0.0 (Medium) | Bind to a specific interface |
| Downgrading a finding without tracing it (High) | Trace data flow first; document with a `// security:` comment |

## Cross-references

- → See `go-database` for parameterized queries
- → See `go-safety` for race and shared-state safety
- → See `go-lint` for security-relevant linters (bodyclose, sqlclosecheck, gosec)
- → See `go-dependency-management` for govulncheck usage
- → See `go-continuous-integration` for automated security review in CI
