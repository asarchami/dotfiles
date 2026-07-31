---
name: go-cli
description: "Golang CLI application development, including deep spf13/cobra and spf13/viper usage. Use when building, modifying, or reviewing a Go CLI tool — command structure, flag handling, configuration layering, version embedding, exit codes, I/O patterns, signal handling, shell completion, argument validation, and CLI unit testing. Covers cobra.Command, RunE vs Run, PersistentPreRunE hook chain, Args validators, command groups, ValidArgsFunction, doc generation, and viper's layered precedence (flag > env > file > KV > default), BindPFlag, SetEnvPrefix, Unmarshal/mapstructure, WatchConfig hot reload, and viper.New() test isolation. Also triggers when code imports cobra, viper, or urfave/cli."
user-invocable: true
license: MIT
compatibility: Designed for Claude Code or similar AI coding agents, and for projects using Golang.
metadata:
  author: samber
  version: "1.2.0"
  openclaw:
    emoji: "💻"
    homepage: https://github.com/samber/cc-skills-golang
    requires:
      bins:
        - go
    install: []
---

**Persona:** You are a Go CLI engineer. You build tools that feel native to the Unix shell — composable, scriptable, and predictable under automation.

**Modes:**

- **Build** — creating a new CLI from scratch: follow the project structure, root command setup, flag binding, and version embedding sections sequentially.
- **Extend** — adding subcommands, flags, or completions to an existing CLI: read the current command tree first, then apply changes consistent with the existing structure.
- **Review** — auditing an existing CLI for correctness: check the Common Mistakes table, verify `SilenceUsage`/`SilenceErrors`, flag-to-Viper binding, exit codes, and stdout/stderr discipline.

# Go CLI Best Practices

Use Cobra + Viper as the default stack for Go CLI applications. Cobra provides the command/subcommand/flag structure and Viper handles configuration from files, environment variables, and flags with automatic layering. This combination powers kubectl, docker, gh, hugo, and most production Go CLIs.

When using Cobra or Viper, refer to the library's official documentation ([pkg.go.dev/github.com/spf13/cobra](https://pkg.go.dev/github.com/spf13/cobra), [cobra.dev](https://cobra.dev), [pkg.go.dev/github.com/spf13/viper](https://pkg.go.dev/github.com/spf13/viper)) and code examples for current API signatures. This skill is not exhaustive — Context7 can help as a discoverability platform.

For trivial single-purpose tools with no subcommands and few flags, stdlib `flag` is sufficient.

### Cobra vs. Viper

These libraries do fundamentally different things and can be used independently.

| Concern | cobra | viper |
| --- | --- | --- |
| Owns | Command tree, flags, arg validation, completions | Configuration value resolution |
| User-facing? | Yes — subcommands, flags, help text | No — purely a key-value resolver |
| Without the other? | Yes — a CLI with flags only needs cobra | Yes — a daemon reading YAML + env needs only viper |
| Integration seam | Hands `pflag.Flag` to viper via `BindPFlag` | Treats the cobra flag as the highest-precedence layer |

**Use cobra alone** when your binary takes flags and args but needs no config file or env resolution. **Use viper alone** when you have a long-running service reading config from YAML + env with no CLI subcommands. Use both when you need both — bind at `PersistentPreRunE` on the root command.

## Quick Reference

| Concern             | Package / Tool                       |
| ------------------- | ------------------------------------ |
| Commands & flags    | `github.com/spf13/cobra`             |
| Configuration       | `github.com/spf13/viper`             |
| Flag parsing        | `github.com/spf13/pflag` (via Cobra) |
| Colored output      | `github.com/fatih/color`             |
| Table output        | `github.com/olekukonko/tablewriter`  |
| Interactive prompts | `github.com/charmbracelet/bubbletea` |
| Version injection   | `go build -ldflags`                  |
| Distribution        | `goreleaser`                         |

## Project Structure

Organize CLI commands in `cmd/myapp/` with one file per command. Keep `main.go` minimal — it only calls `Execute()`.

```
myapp/
├── cmd/
│   └── myapp/
│       ├── main.go              # package main, only calls Execute()
│       ├── root.go              # Root command + Viper init
│       ├── serve.go             # "serve" subcommand
│       ├── migrate.go           # "migrate" subcommand
│       └── version.go           # "version" subcommand
├── go.mod
└── go.sum
```

`main.go` should be minimal — see [assets/examples/main.go](assets/examples/main.go).

## Root Command Setup

The root command initializes Viper configuration and sets up global behavior via `PersistentPreRunE`. See [assets/examples/root.go](assets/examples/root.go).

Key points:

- `SilenceUsage: true` MUST be set — prevents printing the full usage text on every error
- `SilenceErrors: true` MUST be set — lets you control error output format yourself
- `PersistentPreRunE` runs before every subcommand, so config is always initialized
- Logs go to stderr, output goes to stdout

### The Run* hook chain

Cobra commands have five run hooks executed in order:

```
PersistentPreRunE → PreRunE → RunE → PostRunE → PersistentPostRunE
```

Always use the `*E` variants — the non-`E` forms cannot return an error, so the only escape is `os.Exit` or panic, which bypasses defers. Key rules:

- `PersistentPreRunE` on the root runs before **every** subcommand — use it for config init and auth checks
- A child's `PersistentPreRunE` **replaces** the parent's entirely (cobra does not chain them) — call the parent explicitly if you need both
- `PostRunE` runs only if `RunE` succeeded

For the full lifecycle and inheritance rules, see [Cobra: Commands and Args](references/cobra-commands-and-args.md).

## Subcommands

Add subcommands by creating separate files in `cmd/myapp/` and registering them in `init()`. See [assets/examples/serve.go](assets/examples/serve.go) for a complete subcommand example including command groups.

Use `AddGroup` to label subcommands in help output — register groups **before** the `AddCommand` calls that reference them; cobra does not retroactively assign groups.

## Flags

Cobra delegates flag parsing to `pflag`. See [assets/examples/flags.go](assets/examples/flags.go) for all flag patterns:

### Persistent vs Local

- **Persistent** flags (`PersistentFlags()`) are inherited by all subcommands (e.g., `--config`)
- **Local** flags (`Flags()`) only apply to the command they're defined on (e.g., `--port`)

```go
rootCmd.PersistentFlags().StringVar(&cfgFile, "config", "", "config file path") // inherited by all subcommands
serveCmd.Flags().IntVar(&port, "port", 8080, "listen port")                     // local to serveCmd only
```

### Required Flags

Use `MarkFlagRequired`, `MarkFlagsMutuallyExclusive`, and `MarkFlagsOneRequired` for flag constraints.

### Flag Validation with RegisterFlagCompletionFunc

Provide completion suggestions for flag values.

### Always Bind Flags to Viper

This ensures `viper.GetInt("port")` returns the flag value, env var `MYAPP_PORT`, or config file value — whichever has highest precedence. Bind in `init()` or `PersistentPreRunE` — never in `RunE` (too late; cobra parses flags before `RunE` runs).

For pflag types, custom flag values, flag groups, and viper binding in depth, see [Cobra: Flags](references/cobra-flags.md).

## Argument Validation

Cobra validates positional arguments before `RunE` runs. Never write `len(args)` checks inside `RunE` — that bypasses cobra's standard error messages ("accepts 1 arg, received 2") and arg count tracking. See [assets/examples/args.go](assets/examples/args.go) for both built-in and custom validation examples.

| Validator                   | Description                          |
| --------------------------- | ------------------------------------ |
| `cobra.NoArgs`              | Fails if any args provided           |
| `cobra.ExactArgs(n)`        | Requires exactly n args              |
| `cobra.MinimumNArgs(n)`     | Requires at least n args             |
| `cobra.MaximumNArgs(n)`     | Allows at most n args                |
| `cobra.RangeArgs(min, max)` | Requires between min and max         |
| `cobra.OnlyValidArgs`       | Args must be in `ValidArgs`          |
| `cobra.ExactValidArgs(n)`   | Exactly n args, must be in ValidArgs |

Compose multiple validators with `cobra.MatchAll(v1, v2)`. Custom validator signature: `func(cmd *cobra.Command, args []string) error`.

For the full validator set with examples and `MatchAll` patterns, see [Cobra: Commands and Args](references/cobra-commands-and-args.md).

## Configuration with Viper

Viper has no user-facing surface — it doesn't define commands or flags. Its job is to answer "what is the value of key X right now?" by walking its source layers from highest to lowest priority:

```
1. explicit Set()      — viper.Set("key", val)    highest priority
2. flag                — bound pflag.Flag
3. env var             — BindEnv / AutomaticEnv
4. config file         — ReadInConfig / MergeInConfig
5. KV remote           — etcd / Consul
6. default             — viper.SetDefault("key", val)   lowest priority
```

This pipeline is fixed and cannot be reordered. Understanding it prevents most viper bugs: a key that "should" come from a config file may be shadowed by an env var or a flag with a default value.

See [assets/examples/config.go](assets/examples/config.go) for complete Viper integration including struct unmarshaling and config file watching.

### Example Config File (.myapp.yaml)

```yaml
port: 8080
host: localhost
log-level: info
database:
  dsn: postgres://localhost:5432/myapp
  max-conn: 25
```

With the setup above, these are all equivalent:

- Flag: `--port 9090`
- Env var: `MYAPP_PORT=9090`
- Config file: `port: 9090`

For supported formats (JSON, TOML, YAML, HCL, INI, properties), `MergeInConfig`, and remote KV, see [Viper: Sources and Formats](references/viper-sources-and-formats.md).

### Env binding and key replacers

This is the highest-bug-density area in viper. All three settings must be wired together — missing any one breaks nested key resolution:

```go
// ✓ Good — all three wired together at startup
viper.SetEnvPrefix("MYAPP")                             // prevent collisions: PORT → MYAPP_PORT
viper.SetEnvKeyReplacer(strings.NewReplacer(".", "_"))  // database.host → MYAPP_DATABASE_HOST
viper.AutomaticEnv()

// ✗ Bad — without SetEnvKeyReplacer, viper looks for MYAPP_DATABASE.HOST (dot preserved)
```

For `BindEnv`, `AllowEmptyEnv`, and env-vs-default interaction, see [Viper: Binding and Env](references/viper-binding-and-env.md).

### Unmarshaling into structs

`viper.Unmarshal` maps the resolved configuration into a struct using `mapstructure`. **Always use `mapstructure` tags** — implicit mapping is fragile for nested structs and underscore-named fields. Prefer `viper.UnmarshalKey("database", &dbCfg)` over `Sub("database").Unmarshal` — it avoids the nil-check `Sub` requires when the key is missing (`Sub` returns `nil` if the key doesn't exist).

For `time.Duration` / `net.IP` / slice decoders and custom `DecodeHook` registration, see [Viper: Unmarshal](references/viper-unmarshal.md).

### Hot reload

```go
viper.WatchConfig()
viper.OnConfigChange(func(e fsnotify.Event) { /* re-apply changed values */ })
```

`WatchConfig` uses fsnotify and watches inodes. Editors that write atomically via rename (vim, neovim) replace the inode — the callback may not fire. Test hot-reload with `echo >> config.yaml`, not editor saves. For race-safe reload patterns, see [Viper: Watch and Reload](references/viper-watch-and-reload.md).

### Test isolation

**Never use the global viper in tests** — state leaks across test cases. Use `viper.New()` per test so each instance is isolated:

```go
v := viper.New()
v.SetConfigFile("testdata/config.yaml")
require.NoError(t, v.ReadInConfig())
```

For `t.Setenv` interactions and `Reset()` limitations, see [Viper: Testing and Isolation](references/viper-testing-and-isolation.md).

## Version and Build Info

Version SHOULD be embedded at compile time using `ldflags`. See [assets/examples/version.go](assets/examples/version.go) for the version command and build instructions.

## Exit Codes

Exit codes MUST follow Unix conventions:

| Code  | Meaning           | When to Use                               |
| ----- | ----------------- | ----------------------------------------- |
| 0     | Success           | Operation completed normally              |
| 1     | General error     | Runtime failure                           |
| 2     | Usage error       | Invalid flags or arguments                |
| 64-78 | BSD sysexits      | Specific error categories                 |
| 126   | Cannot execute    | Permission denied                         |
| 127   | Command not found | Missing dependency                        |
| 128+N | Signal N          | Terminated by signal (e.g., 130 = SIGINT) |

See [assets/examples/exit_codes.go](assets/examples/exit_codes.go) for a pattern mapping errors to exit codes.

## I/O Patterns

See [assets/examples/output.go](assets/examples/output.go) for all I/O patterns:

- **stdout vs stderr**: NEVER write diagnostic output to stdout — stdout is for program output (pipeable), stderr for logs/errors/diagnostics
- **Detecting pipe vs terminal**: check `os.ModeCharDevice` on stdout
- **Machine-readable output**: support `--output` flag for table/json/plain formats
- **Colors**: use `fatih/color` which auto-disables when output is not a terminal

## Signal Handling

Signal handling MUST use `signal.NotifyContext` to propagate cancellation through context. See [assets/examples/signal.go](assets/examples/signal.go) for graceful HTTP server shutdown.

## Shell Completions

Cobra generates completions for bash, zsh, fish, and PowerShell automatically. See [assets/examples/completion.go](assets/examples/completion.go) for both the completion command and custom flag/argument completions. Extend completions with:

- **`ValidArgs []string`** — static positional arg completion
- **`ValidArgsFunction`** — dynamic: `func(cmd, args, toComplete string) ([]string, ShellCompDirective)`. Return `ShellCompDirectiveNoFileComp` to suppress file fallback
- **`RegisterFlagCompletionFunc(name, fn)`** — flag value completion

For `ShellCompDirective` values, annotations, and testing completions, see [Cobra: Completions](references/cobra-completions.md).

## Documentation Generation

Cobra can generate man pages, Markdown, YAML, and RST docs directly from the command tree, and the `cobra-cli` tool scaffolds new commands/projects. See [Cobra: Generators](references/cobra-generators.md).

## Testing CLI Commands

Test commands by executing them programmatically and capturing output. See [assets/examples/cli_test.go](assets/examples/cli_test.go).

Use `cmd.OutOrStdout()` and `cmd.ErrOrStderr()` in commands (instead of `os.Stdout` / `os.Stderr`) so output can be captured in tests:

```go
func TestServeCmd(t *testing.T) {
    buf := new(bytes.Buffer)
    rootCmd.SetOut(buf)
    rootCmd.SetArgs([]string{"serve", "--port", "9090"})
    require.NoError(t, rootCmd.Execute())
    assert.Contains(t, buf.String(), "listening on :9090")
}
```

Cobra accumulates flag state across `Execute()` calls — build a fresh command tree per test, not a shared package-level `rootCmd`. For isolation patterns, golden files, and testing completions, see [Cobra: Testing](references/cobra-testing.md). For viper's parallel isolation rule (`viper.New()` per test), see [Viper: Testing and Isolation](references/viper-testing-and-isolation.md).

## Common Mistakes

| Mistake | Fix |
| --- | --- |
| Writing to `os.Stdout` directly | Tests can't capture output. Use `cmd.OutOrStdout()` which tests can redirect to a buffer |
| Calling `os.Exit()` inside `RunE` | Cobra's error handling, deferred functions, and cleanup code never run. Return an error, let `main()` decide |
| Not binding flags to Viper | Flags won't be configurable via env/config. Call `viper.BindPFlag` for every configurable flag |
| Missing `viper.SetEnvPrefix` | `PORT` collides with other tools. Use a prefix (`MYAPP_PORT`) to namespace env vars |
| Logging to stdout | Unix pipes chain stdout — logs corrupt the data stream for the next program. Logs go to stderr |
| Printing usage on every error | Full help text on every error is noise. Set `SilenceUsage: true`, save full usage for `--help` |
| Config file required | Users without a config file get a crash. Ignore `viper.ConfigFileNotFoundError` — config should be optional |
| Not using `PersistentPreRunE` | Config initialization must happen before any subcommand. Use root's `PersistentPreRunE` |
| Hardcoded version string | Version gets out of sync with tags. Inject via `ldflags` at build time from git tags |
| Not supporting `--output` format | Scripts can't parse human-readable output. Add JSON/table/plain for machine consumption |
| Using `Run` instead of `RunE` | `Run` cannot return an error — only escape is `os.Exit` or panic, bypassing defers. Use `RunE` |
| Writing `len(args)` checks in `RunE` | Bypasses cobra's standard error messages. Declare `Args: cobra.ExactArgs(1)` on the command instead |
| Child `PersistentPreRunE` silently drops parent's | Cobra does not chain — the child replaces the parent's hook entirely. Call `parent.PersistentPreRunE(cmd, args)` from the child's hook |
| Reusing a root command across tests | Cobra accumulates flag state; second `Execute()` sees flags from the first. Build a fresh command tree per test |
| `AutomaticEnv` without `SetEnvKeyReplacer` | `database.host` looks for `MYAPP_DATABASE.HOST` (dot preserved) — never matches. Add `SetEnvKeyReplacer` before `AutomaticEnv` |
| No `mapstructure` tags on struct fields | Silently misses nested and underscore-named fields. Add `mapstructure:"key_name"` to every field |
| Using global viper in tests | State from one test contaminates the next, causing flaky ordering. Create `viper.New()` per test |

## Related Skills

- → See `go-project-layout` skill for overall project structure
- → See `go-dependency-injection` skill for wiring dependencies into commands
- → See `go-testing` skill for general Go testing patterns
- → See `go-code-style` skill for graceful shutdown and other design patterns used in CLI code
