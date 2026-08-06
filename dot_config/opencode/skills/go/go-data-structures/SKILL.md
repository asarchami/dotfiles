---
name: go-data-structures
description: "Go data-structure internals — slices, maps, arrays, container/list-heap-ring, strings.Builder vs bytes.Buffer, generic collections, unsafe/weak pointers, copy semantics. Use when choosing or optimizing a Go data structure, implementing generic containers, using container/ packages or unsafe/weak pointers, or questioning slice/map internals."
license: MIT
---

# Go Data Structures

**Leading word: internals.** Every structure carries a hidden cost — allocation, reallocation, and copying — that only shows under load. The discipline is to choose the right structure by its **internals** (memory layout, allocation cost, access pattern) rather than familiarity, and to preallocate and avoid growth whenever the size is known.

## Steps — choose and use

1. **Start with the right default.** Slices over arrays unless the size is fixed at compile time; maps when you need keyed lookup; arrays only for fixed compile-time sizes (digests, IPv4, matrix dims) since arrays pass by value.

   *Done when: each collection is a slice unless a fixed compile-time size or keyed access is the reason for the alternative.*

2. **Preallocate when size is known.** `make([]T, 0, n)` for slices and `make(map[K]V, n)` for maps avoid repeated growth copies and rehashing; `slices.Grow` (Go 1.21+) pre-grows before a bulk append.

   *Done when: every growable collection with a known or estimable size is preallocated.*

3. **Don't rely on capacity-growth timing.** The growth algorithm changed across Go versions and can change again (doubling under 256 elements, ~25% growth beyond). Code must not depend on when a new backing array is allocated.

   *Done when: no code depends on a specific growth step or backing-array reuse.*

4. **Match the container to the access pattern.** `container/heap` for priority queues, `container/list` only for frequent middle insertions, `container/ring` for fixed-size circular buffers, `bufio` for buffered I/O. Container types use `any` — wrap them in generics for type safety.

   *Done when: each container choice is justified by the access pattern, not convenience.*

5. **Build strings, don't concatenate them.** `strings.Builder` for pure string building (its `String()` avoids a copy); `bytes.Buffer` when you need `io.Reader`/`io.Writer` or byte manipulation. Both support `Grow(n)`.

   *Done when: no hot loop builds a string by `+=`, and no `bytes.Buffer` is used for string-only building.*

6. **Use the tightest generic constraint.** `comparable` for map keys and sets, `cmp.Ordered` for sorting, custom interfaces for domain-specific ordering.

   *Done when: every generic container's constraint is the tightest one that still accepts its uses.*

7. **Respect pointer rules.** `unsafe.Pointer` only via the 6 spec conversion patterns — stored as a pointer, never held in a `uintptr` across statements (GC can move the object). Use `weak.Pointer[T]` (Go 1.24+) for caches and canonicalization maps so the GC can reclaim entries.

   *Done when: no `uintptr` holds a pointer across statements and every unsafe conversion follows a spec pattern.*

## Steps — review or audit

1. **Check growth in loops.** Appending inside a loop without preallocation copies the backing array on each growth. *Done when: every such loop preallocates or uses `slices.Grow`.*
2. **Check `container/list` where a slice suffices.** Linked lists have poor cache locality — benchmark first. *Done when: each linked list is justified by frequent middle insertion/removal.*
3. **Check `bytes.Buffer` for pure string building.** Its `String()` copies; `strings.Builder` avoids it. *Done when: string-only builds use `strings.Builder`.*
4. **Check `unsafe.Pointer` stored as `uintptr`.** The value dangles if the GC moves the object between statements. *Done when: no `uintptr` persists a pointer.*
5. **Check large value structs in maps.** Map access copies the entire value per lookup. *Done when: large value types are stored as `map[K]*V`.*

## Reference

### Slice internals

A slice is a 3-word header: pointer, length, capacity. Multiple slices can share a backing array — see `go-safety` for aliasing traps and the header diagram.

- Capacity growth: under 256 elements the capacity doubles; at 256+ it grows by ~25%; each growth copies the entire backing array — O(n).
- Preallocation: `make([]User, 0, len(ids))`, `make([]Result, 0, estimatedCount)`, `slices.Grow(s, additionalNeeded)`.
- `slices` package (Go 1.21+): `Sort`/`SortFunc`, `BinarySearch`, `Contains`, `Compact`, `Grow`. For `Clone`, `Equal`, `DeleteFunc` → see `go-safety`.

**[Slice Internals Deep Dive](./references/slice-internals.md)** — full `slices` package reference, growth mechanics, `len` vs `cap`, header copying, backing-array aliasing.

### Map internals

Maps are hash tables with 8-entry buckets and overflow chains. They are reference types — assigning a map copies the pointer, not the data. Preallocate with `make(map[string]*User, len(users))` to avoid rehashing during population.

`maps` package (Go 1.21+):

| Function | Purpose |
| --- | --- |
| `Collect` (1.23+) | Build map from iterator |
| `Insert` (1.23+) | Insert entries from iterator |
| `All` (1.23+) | Iterator over all entries |
| `Keys`, `Values` | Iterators over keys/values |

For `Clone`, `Equal`, sorted iteration → see `go-safety`.

**[Map Internals Deep Dive](./references/map-internals.md)** — how maps store and hash data, bucket overflow chains, why maps never shrink (and what to do about it), map vs alternatives performance.

### Arrays

Fixed-size, value types — copied entirely on assignment. Use for compile-time-known sizes:

```go
type Digest [32]byte         // fixed-size, value type
var grid [3][3]int           // multi-dimensional
cache := map[[2]int]Result{} // arrays are comparable — usable as map keys
```

Prefer slices for everything else; arrays cannot grow and pass by value.

### container/ standard library

| Package | Data Structure | Best For |
| --- | --- | --- |
| `container/list` | Doubly-linked list | LRU caches, frequent middle insertion/removal |
| `container/heap` | Min-heap (priority queue) | Top-K, scheduling, Dijkstra |
| `container/ring` | Circular buffer | Rolling windows, round-robin |
| `bufio` | Buffered reader/writer/scanner | Efficient I/O with small reads/writes |

**[Container Patterns, bufio, and Examples](./references/containers.md)** — when to use each container, generic wrappers to add type safety, and `bufio` patterns for efficient I/O.

### Generic collections (Go 1.18+)

```go
type Set[T comparable] map[T]struct{}

func (s Set[T]) Add(v T)           { s[v] = struct{}{} }
func (s Set[T]) Contains(v T) bool { _, ok := s[v]; return ok }
```

**[Writing Generic Data Structures](./references/generics.md)** — using Go 1.18+ generics for type-safe containers, constraint satisfaction, and domain-specific generic types.

### Pointer types

| Type | Use Case | Zero Value |
| --- | --- | --- |
| `*T` | Normal indirection, mutation, optional values | `nil` |
| `unsafe.Pointer` | FFI, low-level memory layout (6 spec patterns only) | `nil` |
| `weak.Pointer[T]` (1.24+) | Caches, canonicalization, weak references | N/A |

**[Pointer Types Deep Dive](./references/pointers.md)** — normal pointers, `unsafe.Pointer` (the 6 valid spec patterns), and `weak.Pointer[T]` for GC-safe caches that don't prevent cleanup.

### Copy semantics

| Type | Copy Behavior | Independence |
| --- | --- | --- |
| `int`, `float`, `bool`, `string` | Value (deep copy) | Fully independent |
| `array`, `struct` | Value (deep copy) | Fully independent |
| `slice` | Header copied, backing array shared | Use `slices.Clone` |
| `map` | Reference copied | Use `maps.Clone` |
| `channel` | Reference copied | Same channel |
| `*T` (pointer) | Address copied | Same underlying value |
| `interface` | Value copied (type + value pair) | Depends on held type |

### Third-party libraries

- **`emirpasic/gods`** — comprehensive collection library (trees, sets, lists, stacks, maps, queues)
- **`deckarep/golang-set`** — thread-safe and non-thread-safe set implementations
- **`gammazero/deque`** — fast double-ended queue

Refer to official documentation for current API signatures.

### External references

- [Go Data Structures (Russ Cox)](https://research.swtch.com/godata)
- [The Go Memory Model](https://go.dev/ref/mem)
- [Effective Go](https://go.dev/doc/effective_go)

## Watch for

| Mistake | Fix |
| --- | --- |
| Growing a slice in a loop without preallocation | `make([]T, 0, n)` or `slices.Grow` |
| `container/list` when a slice would suffice | Linked lists have poor cache locality — benchmark first |
| `bytes.Buffer` for pure string building | `strings.Builder` (avoids the copy on `String()`) |
| `unsafe.Pointer` stored as `uintptr` across statements | The GC can move the object — keep the pointer typed |
| Large struct values in maps | `map[K]*V` to avoid copying the value per access |
| `any` in generic collections | Tightest constraint (`comparable`, `cmp.Ordered`) |

## Cross-references

- → See `go-performance` for struct field alignment, memory layout optimization, and cache locality
- → See `go-safety` for nil map/slice pitfalls, append aliasing, defensive copying, `slices.Clone`/`Equal`
- → See `go-concurrency` for channels, `sync.Map`, `sync.Pool`, and all sync primitives
- → See `go-patterns` for `string` vs `[]byte` vs `[]rune`, iterators, streaming
- → See `go-structs-interfaces` for struct composition, embedding, and generics vs `any`
