---
name: go-data-structures
description: "Golang data structures — slices (internals, capacity growth, preallocation, slices package), maps (internals, hash buckets, maps package), arrays, container/list/heap/ring, strings.Builder vs bytes.Buffer, generic collections, pointers (unsafe.Pointer, weak.Pointer), and copy semantics. Use when choosing or optimizing Go data structures, implementing generic containers, using container/ packages, unsafe or weak pointers, or questioning slice/map internals."
user-invocable: true
license: MIT
compatibility: Designed for Claude Code or similar AI coding agents, and for projects using Golang.
metadata:
  author: samber
  version: "1.1.1"
  openclaw:
    emoji: "🗃️"
    homepage: https://github.com/samber/cc-skills-golang
    requires:
      bins:
        - go
    install: []
---

**Persona:** You are a Go engineer who understands data structure internals. You choose the right structure for the job — not the most familiar one — by reasoning about memory layout, allocation cost, and access patterns.

# Go Data Structures

Built-in and standard library data structures: internals, correct usage, and selection guidance. For safety pitfalls (nil maps, append aliasing, defensive copies) see `go-safety` skill. For channels and sync primitives see `go-concurrency` skill. For string/byte/rune choice see `go-design-patterns` skill.

## Best Practices Summary

1. **Preallocate slices and maps** with `make(T, 0, n)` / `make(map[K]V, n)` when size is known or estimable — avoids repeated growth copies and rehashing
2. **Arrays** SHOULD be preferred over slices only for fixed, compile-time-known sizes (hash digests, IPv4 addresses, matrix dimensions)
3. **NEVER rely on slice capacity growth timing** — the growth algorithm changed between Go versions and may change again; your code should not depend on when a new backing array is allocated
4. **Use `container/heap`** for priority queues, **`container/list`** only when frequent middle insertions are needed, **`container/ring`** for fixed-size circular buffers
5. **`strings.Builder`** MUST be preferred for building strings; **`bytes.Buffer`** MUST be preferred for bidirectional I/O (implements both `io.Reader` and `io.Writer`)
6. Generic data structures SHOULD use the **tightest constraint** possible — `comparable` for keys, custom interfaces for ordering
7. **`unsafe.Pointer`** MUST only follow the 6 valid conversion patterns from the Go spec — NEVER store in a `uintptr` variable across statements
8. **`weak.Pointer[T]`** (Go 1.24+) SHOULD be used for caches and canonicalization maps to allow GC to reclaim entries

## Slice Internals

A slice is a 3-word header: pointer, length, capacity. Multiple slices can share a backing array (→ see `go-safety` for aliasing traps and the header diagram).

### Capacity Growth

- < 256 elements: capacity doubles
- > = 256 elements: grows by ~25% (`newcap += (newcap + 3*256) / 4`)
- Each growth copies the entire backing array — O(n)

### Preallocation

```go
// Exact size known
users := make([]User, 0, len(ids))

// Approximate size known
results := make([]Result, 0, estimatedCount)

// Pre-grow before bulk append (Go 1.21+)
s = slices.Grow(s, additionalNeeded)
```

### `slices` Package (Go 1.21+)

Key functions: `Sort`/`SortFunc`, `BinarySearch`, `Contains`, `Compact`, `Grow`. For `Clone`, `Equal`, `DeleteFunc` → see `go-safety` skill.

**[Slice Internals Deep Dive](./references/slice-internals.md)** — Full `slices` package reference, growth mechanics, `len` vs `cap`, header copying, backing array aliasing.

## Map Internals

Maps are hash tables with 8-entry buckets and overflow chains. They are reference types — assigning a map copies the pointer, not the data.

### Preallocation

```go
m := make(map[string]*User, len(users)) // avoids rehashing during population
```

### `maps` Package Quick Reference (Go 1.21+)

| Function          | Purpose                      |
| ----------------- | ---------------------------- |
| `Collect` (1.23+) | Build map from iterator      |
| `Insert` (1.23+)  | Insert entries from iterator |
| `All` (1.23+)     | Iterator over all entries    |
| `Keys`, `Values`  | Iterators over keys/values   |

For `Clone`, `Equal`, sorted iteration → see `go-safety` skill.

**[Map Internals Deep Dive](./references/map-internals.md)** — How Go maps store and hash data, bucket overflow chains, why maps never shrink (and what to do about it), comparing map performance to alternatives.

## Arrays

Fixed-size, value types. Copied entirely on assignment. Use for compile-time-known sizes:

```go
type Digest [32]byte           // fixed-size, value type
var grid [3][3]int             // multi-dimensional
cache := map[[2]int]Result{}   // arrays are comparable — usable as map keys
```

Prefer slices for everything else — arrays cannot grow and pass by value (expensive for large sizes).

## container/ Standard Library

| Package | Data Structure | Best For |
| --- | --- | --- |
| `container/list` | Doubly-linked list | LRU caches, frequent middle insertion/removal |
| `container/heap` | Min-heap (priority queue) | Top-K, scheduling, Dijkstra |
| `container/ring` | Circular buffer | Rolling windows, round-robin |
| `bufio` | Buffered reader/writer/scanner | Efficient I/O with small reads/writes |

Container types use `any` (no type safety) — consider generic wrappers. **[Container Patterns, bufio, and Examples](./references/containers.md)** — When to use each container type, generic wrappers to add type safety, and `bufio` patterns for efficient I/O.

## strings.Builder vs bytes.Buffer

Use `strings.Builder` for pure string concatenation (avoids copy on `String()`), `bytes.Buffer` when you need `io.Reader` or byte manipulation. Both support `Grow(n)`. **[Details and comparison](./references/containers.md)**

## Generic Collections (Go 1.18+)

Use the tightest constraint possible. `comparable` for map keys, `cmp.Ordered` for sorting, custom interfaces for domain-specific ordering.

```go
type Set[T comparable] map[T]struct{}

func (s Set[T]) Add(v T)          { s[v] = struct{}{} }
func (s Set[T]) Contains(v T) bool { _, ok := s[v]; return ok }
```

**[Writing Generic Data Structures](./references/generics.md)** — Using Go 1.18+ generics for type-safe containers, understanding constraint satisfaction, and building domain-specific generic types.

## Pointer Types

| Type | Use Case | Zero Value |
| --- | --- | --- |
| `*T` | Normal indirection, mutation, optional values | `nil` |
| `unsafe.Pointer` | FFI, low-level memory layout (6 spec patterns only) | `nil` |
| `weak.Pointer[T]` (1.24+) | Caches, canonicalization, weak references | N/A |

**[Pointer Types Deep Dive](./references/pointers.md)** — Normal pointers, `unsafe.Pointer` (the 6 valid spec patterns), and `weak.Pointer[T]` for GC-safe caches that don't prevent cleanup.

## Copy Semantics Quick Reference

| Type | Copy Behavior | Independence |
| --- | --- | --- |
| `int`, `float`, `bool`, `string` | Value (deep copy) | Fully independent |
| `array`, `struct` | Value (deep copy) | Fully independent |
| `slice` | Header copied, backing array shared | Use `slices.Clone` |
| `map` | Reference copied | Use `maps.Clone` |
| `channel` | Reference copied | Same channel |
| `*T` (pointer) | Address copied | Same underlying value |
| `interface` | Value copied (type + value pair) | Depends on held type |

## Third-Party Libraries

For advanced data structures (trees, sets, queues, stacks) beyond the standard library:

- **`emirpasic/gods`** — comprehensive collection library (trees, sets, lists, stacks, maps, queues)
- **`deckarep/golang-set`** — thread-safe and non-thread-safe set implementations
- **`gammazero/deque`** — fast double-ended queue

When using third-party libraries, refer to their official documentation and code examples for current API signatures. Context7 can help as a discoverability platform.

## Cross-References

- → See `go-performance` skill for struct field alignment, memory layout optimization, and cache locality
- → See `go-safety` skill for nil map/slice pitfalls, append aliasing, defensive copying, `slices.Clone`/`Equal`
- → See `go-concurrency` skill for channels, `sync.Map`, `sync.Pool`, and all sync primitives
- → See `go-design-patterns` skill for `string` vs `[]byte` vs `[]rune`, iterators, streaming
- → See `go-structs-interfaces` skill for struct composition, embedding, and generics vs `any`
- → See `go-code-style` skill for slice/map initialization style

## Common Mistakes

| Mistake | Fix |
| --- | --- |
| Growing a slice in a loop without preallocation | Each growth copies the entire backing array — O(n) per growth. Use `make([]T, 0, n)` or `slices.Grow` |
| Using `container/list` when a slice would suffice | Linked lists have poor cache locality (each node is a separate heap allocation). Benchmark first |
| `bytes.Buffer` for pure string building | Buffer's `String()` copies the underlying bytes. `strings.Builder` avoids this copy |
| `unsafe.Pointer` stored as `uintptr` across statements | GC can move the object between statements — the `uintptr` becomes a dangling reference |
| Large struct values in maps (copying overhead) | Map access copies the entire value. Use `map[K]*V` for large value types to avoid the copy |

## References

- [Go Data Structures (Russ Cox)](https://research.swtch.com/godata)
- [The Go Memory Model](https://go.dev/ref/mem)
- [Effective Go](https://go.dev/doc/effective_go)
