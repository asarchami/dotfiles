# Neovim Keymaps Reference

This document contains all key mappings configured in this Neovim setup. The configuration uses a smart system where universal operations are always available, while language-specific mappings appear only when working on relevant projects.

## Table of Contents

- [Leader Key](#leader-key)
- [Universal Keymaps (Always Available)](#universal-keymaps-always-available)
  - [Non-Leader Mappings](#non-leader-mappings)
  - [File Operations (`<leader>f`)](#file-operations-leaderf)
  - [Git Operations (`<leader>g`)](#git-operations-leaderg)
    - [Git Hunk Operations (`<leader>gh`)](#git-hunk-operations-leadergh)
  - [Buffer Operations (`<leader>b`)](#buffer-operations-leaderb)
  - [Window/Split Operations (`<leader>w`)](#windowsplit-operations-leaderw)
  - [Tab Operations (`<leader>T`)](#tab-operations-leadert)
  - [Search Operations (`<leader>s`)](#search-operations-leaders)
  - [Telescope Operations (`<leader>t`)](#telescope-operations-leadert)
  - [Universal Code Operations (`<leader>c`)](#universal-code-operations-leaderc)
  - [Clipboard Operations](#clipboard-operations)
  - [Quick Actions](#quick-actions)
- [Language-Specific Keymaps (Conditional)](#language-specific-keymaps-conditional)
  - [Python Projects](#python-projects-leaderd-leadercp)
    - [Debug Operations (`<leader>d`)](#debug-operations-leaderd)
    - [Python-Specific Operations (`<leader>cp`)](#python-specific-operations-leadercp)
  - [Go Projects](#go-projects-leaderd-leadercg)
    - [Debug Operations (`<leader>d`)](#debug-operations-leaderd-1)
    - [Go-Specific Operations (`<leader>cg`)](#go-specific-operations-leadercg)
      - [Running and Building](#running-and-building)
      - [Code Generation](#code-generation)
      - [Documentation and Navigation](#documentation-and-navigation)
      - [Formatting and Linting](#formatting-and-linting)
- [Smart Context System](#smart-context-system)
  - [How It Works](#how-it-works)
  - [Project Detection](#project-detection)
  - [Discovery](#discovery)
- [Tmux Integration](#tmux-integration)
- [Customization](#customization)
  - [Adding New Languages](#adding-new-languages)
  - [Modifying Existing Mappings](#modifying-existing-mappings)

## Leader Key

**Leader Key**: `<Space>`

## Universal Keymaps (Always Available)

### Non-Leader Mappings

These mappings work without the leader key:

| Key Binding | Mode | Description |
|-------------|------|-------------|
| `jk` | Insert | Better escape |
| `Ctrl+h/j/k/l` | Normal | Navigate between windows and tmux panes |
| `Ctrl+Up/Down` | Normal | Resize windows vertically |
| `Ctrl+Left/Right` | Normal | Resize windows horizontally |
| `Shift+h/l` | Normal | Navigate between buffers |
| `Alt+j/k` | Visual | Move text up/down |
| `[d` / `]d` | Normal | Previous/next diagnostic |
| `Ctrl+s` | Normal/Insert | Quick save |

### File Operations (`<leader>f`)

| Key Binding | Description |
|-------------|-------------|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep (search in files) |
| `<leader>fb` | Find buffers |
| `<leader>fr` | Recent files |
| `<leader>fw` | Find word under cursor |
| `<leader>fh` | Help tags |
| `<leader>fc` | Change colorscheme |
| `<leader>fe` | File explorer (telescope file browser) |
| `<leader>fE` | File explorer (current directory) |
| `<leader>fn` | New file |
| `<leader>fs` | Save file |
| `<leader>fS` | Save all files |

#### File Browser Operations (`<leader>fe` / `<leader>fE`)

When in telescope file browser, these keys are available:

| Key | Operation | Description |
|-----|-----------|-------------|
| `%` | Create File | Create a new file in current directory |
| `/` | Create Folder | Create a new folder in current directory |
| `r` | Rename | Rename selected file or folder |
| `d` | Delete | **Permanently delete** file/folder |
| `y` | Copy | Copy selected file/folder to clipboard |
| `x` | Cut | Cut selected file/folder to clipboard |
| `p` | Paste | Paste from clipboard to current directory |
| `c` | Create Copy | Create a copy of selected file |
| `<Tab>` | Toggle Selection | Select/deselect current item |
| `<S-Tab>` | Toggle All | Select/deselect all items |
| `h` | Parent Directory | Go up one level |
| `l` | Enter/Open | Enter directory or open file |
| `t` | Toggle Hidden | Show/hide hidden files and folders |
| `s` | Toggle View | Switch between files and folders view |

### Git Operations (`<leader>g`)

| Key Binding | Description |
|-------------|-------------|
| `<leader>gg` | LazyGit |
| `<leader>gs` | Git status |
| `<leader>gb` | Git branches |
| `<leader>gc` | Git commits |
| `<leader>gd` | Git diff |
| `<leader>gp` | Preview hunk |
| `<leader>gr` | Reset hunk |
| `<leader>gR` | Reset buffer |
| `<leader>gl` | Blame line |

#### Git Hunk Operations (`<leader>gh`)

| Key Binding | Description |
|-------------|-------------|
| `<leader>ghs` | Stage hunk |
| `<leader>ghu` | Undo stage hunk |
| `<leader>ghr` | Reset hunk |
| `<leader>ghp` | Preview hunk |
| `<leader>ghd` | Diff this |

### Buffer Operations (`<leader>b`)

**Note**: No visual buffer tabs - use telescope for buffer management.

| Key Binding | Description |
|-------------|-------------|
| `<leader>bd` | Delete buffer |
| `<leader>bD` | Force delete buffer |
| `<leader>bn` | Next buffer (native vim command) |
| `<leader>bp` | Previous buffer (native vim command) |
| `<leader>bf` | Find buffer (telescope picker) |
| `<leader>bl` | List all buffers (telescope picker) |
| `<leader>bs` | Save buffer |
| `<leader>bS` | Save all buffers |
| `<leader>br` | Reload buffer |
| `<leader>bc` | Choose buffer to close (telescope picker) |
| `<leader>bC` | Close all other buffers |
| `<leader>ba` | Close all buffers |

### Window/Split Operations (`<leader>w`)

| Key Binding | Description |
|-------------|-------------|
| `<leader>wv` | Split vertically |
| `<leader>wh` | Split horizontally |
| `<leader>wc` | Close window |
| `<leader>wo` | Only window |
| `<leader>ww` | Switch window |
| `<leader>wr` | Rotate windows |
| `<leader>w=` | Balance windows |
| `<leader>w\|` | Max width |
| `<leader>w_` | Max height |

### Tab Operations (`<leader>T`)

**Note**: Always available, no conflicts with test operations.

| Key Binding | Description |
|-------------|-------------|
| `<leader>Tn` | New tab |
| `<leader>Tc` | Close tab |
| `<leader>To` | Only tab |
| `<leader>Tl` | Next tab |
| `<leader>Th` | Previous tab |
| `<leader>Tf` | First tab |
| `<leader>TL` | Last tab |
| `<leader>Tm` | Move tab |

### Search Operations (`<leader>s`)

| Key Binding | Description |
|-------------|-------------|
| `<leader>sf` | Find files |
| `<leader>sg` | Live grep |
| `<leader>sw` | Find word |
| `<leader>sh` | Clear highlights |
| `<leader>ss` | Search in buffer |
| `<leader>sr` | Resume search |
| `<leader>sc` | Commands |
| `<leader>sk` | Keymaps |
| `<leader>sm` | Marks |

### Telescope Operations (`<leader>t`)

**Note**: This group provides dedicated telescope commands and is always available.

| Key Binding | Description |
|-------------|-------------|
| `<leader>tf` | Find files |
| `<leader>tg` | Live grep |
| `<leader>tb` | Find buffers |
| `<leader>tr` | Recent files |
| `<leader>tw` | Find word |
| `<leader>th` | Help tags |
| `<leader>tc` | Change colorscheme |
| `<leader>te` | File browser |
| `<leader>tE` | File browser (current directory) |
| `<leader>ts` | Search in buffer |
| `<leader>tR` | Resume search |
| `<leader>tC` | Commands |
| `<leader>tk` | Keymaps |
| `<leader>tm` | Marks |

### Universal Code Operations (`<leader>c`)

These work across all file types:

| Key Binding | Description |
|-------------|-------------|
| `<leader>cf` | Format |
| `<leader>cr` | Rename |
| `<leader>ca` | Code action |
| `<leader>cd` | Diagnostics |
| `<leader>ch` | Hover |
| `<leader>cD` | Declaration |
| `<leader>cj` | Jump to definition |
| `<leader>cR` | References |
| `<leader>cs` | Document symbols |
| `<leader>cS` | Workspace symbols |
| `<leader>ci` | LSP info |
| `<leader>cI` | Mason installer |
| `<leader>cx` | Make executable |

### Clipboard Operations

| Key Binding | Mode | Description |
|-------------|------|-------------|
| `<leader>y` | Normal/Visual | Copy to system clipboard |
| `<leader>Y` | Normal | Copy line to system clipboard |
| `<leader>p` | Normal/Visual | Paste from system clipboard |
| `<leader>P` | Normal | Paste before from system clipboard |

### Quick Actions

| Key Binding | Description |
|-------------|-------------|
| `<leader>e` | File browser (telescope file browser) |
| `<leader>o` | File browser (current directory) |
| `<leader>h` | Clear search highlights |
| `<leader>q` | Quit |
| `<leader>Q` | Quit all |
| `<leader>x` | Save and quit |
| `<leader>?` | Show all keymaps |

## Language-Specific Keymaps (Conditional)

These mappings only appear when working on projects with the respective languages installed.

### Python Projects (`<leader>d`, `<leader>cp`)

**Only visible when:**
- Python 3 is installed on the system
- Working in a detected Python project
- Editing `.py` files

**Note**: Test operations have been moved to language-specific Python keybindings to avoid conflicts with the universal telescope operations (`<leader>t`).

| Key Binding | Description |
|-------------|-------------|
| `<leader>tt` | Run nearest test |
| `<leader>tf` | Run file tests |
| `<leader>ta` | Run all tests |
| `<leader>to` | Test output |
| `<leader>ts` | Test summary |
| `<leader>tc` | Cancel test |
| `<leader>tl` | Run last test |
| `<leader>td` | Debug nearest test |
| `<leader>tm` | Debug test method |
| `<leader>tC` | Debug test class |

#### Debug Operations (`<leader>d`)

| Key Binding | Description |
|-------------|-------------|
| `<leader>db` | Toggle breakpoint |
| `<leader>dB` | Conditional breakpoint |
| `<leader>dc` | Continue |
| `<leader>di` | Step into |
| `<leader>do` | Step over |
| `<leader>dO` | Step out |
| `<leader>dr` | Open REPL |
| `<leader>dl` | Run last |
| `<leader>du` | Toggle UI |
| `<leader>dt` | Terminate |
| `<leader>dh` | Hover |
| `<leader>dv` | Preview |
| `<leader>ds` | Debug selection |
| `<leader>df` | Debug current file |

#### Python-Specific Operations (`<leader>cp`)

| Key Binding | Description |
|-------------|-------------|
| `<leader>cps` | Select virtual environment |
| `<leader>cpi` | Select cached virtual environment |
| `<leader>cpe` | Show current virtual environment |
| `<leader>cpr` | Toggle REPL |
| `<leader>cpR` | Focus REPL |
| `<leader>cpz` | Restart REPL |
| `<leader>cph` | Hide REPL |
| `<leader>cpg` | Generate docstring |

### Go Projects (`<leader>d`, `<leader>cg`)

**Only visible when:**
- Go is installed on the system
- Working in a detected Go project
- Editing `.go`, `.mod`, `.work`, or `.tmpl` files

**Note**: Test operations have been moved to language-specific Go keybindings to avoid conflicts with the universal telescope operations (`<leader>t`).

| Key Binding | Description |
|-------------|-------------|
| `<leader>tt` | Run tests |
| `<leader>tf` | Test function |
| `<leader>tp` | Test package |
| `<leader>ta` | Add test |
| `<leader>tc` | Coverage |
| `<leader>tC` | Clear coverage |
| `<leader>tl` | Run last test |
| `<leader>ts` | Test summary |
| `<leader>to` | Test output |
| `<leader>td` | Debug test |
| `<leader>tD` | Debug last test |

#### Debug Operations (`<leader>d`)

| Key Binding | Description |
|-------------|-------------|
| `<leader>db` | Toggle breakpoint |
| `<leader>dB` | Conditional breakpoint |
| `<leader>dc` | Continue |
| `<leader>di` | Step into |
| `<leader>do` | Step over |
| `<leader>dO` | Step out |
| `<leader>dr` | Open REPL |
| `<leader>dl` | Run last |
| `<leader>du` | Toggle UI |
| `<leader>dt` | Terminate |
| `<leader>dh` | Hover |
| `<leader>dv` | Preview |
| `<leader>df` | Debug current file |
| `<leader>dp` | Debug package |

#### Go-Specific Operations (`<leader>cg`)

##### Running and Building

| Key Binding | Description |
|-------------|-------------|
| `<leader>cgr` | Run |
| `<leader>cgR` | Run current file |
| `<leader>cgb` | Build |
| `<leader>cgI` | Install |
| `<leader>cgS` | Stop |

##### Code Generation

| Key Binding | Description |
|-------------|-------------|
| `<leader>cgi` | Implement interface |
| `<leader>cgT` | Add tags |
| `<leader>cgX` | Remove tags |
| `<leader>cgf` | Fill struct |
| `<leader>cge` | Add if err |
| `<leader>cgm` | Go mod tidy |

##### Documentation and Navigation

| Key Binding | Description |
|-------------|-------------|
| `<leader>cgn` | Go doc |
| `<leader>cgB` | Go doc browser |
| `<leader>cgh` | Hierarchy tree |
| `<leader>cgs` | Structure view |

##### Formatting and Linting

| Key Binding | Description |
|-------------|-------------|
| `<leader>cgF` | Format |
| `<leader>cgO` | Organize imports |
| `<leader>cgl` | Lint |
| `<leader>cgv` | Go vet |

## Smart Context System

### How It Works

1. **Universal Operations**: Always available regardless of project type
2. **Conditional Groups**: `<leader>t` and `<leader>d` only appear in supported projects
3. **Language-Specific**: `<leader>cp` (Python) and `<leader>cg` (Go) for specialized operations
4. **Tab Fallback**: `<leader>T` always available when `<leader>t` is not needed

### Project Detection

The system automatically detects project types based on files:

**Python Projects:**
- `requirements.txt`, `pyproject.toml`, `setup.py`, `setup.cfg`
- `Pipfile`, `poetry.lock`, `pyrightconfig.json`
- `.python-version`, `conda.yaml`, `environment.yml`
- Presence of `.py` files

**Go Projects:**
- `go.mod`, `go.sum`, `go.work`, `main.go`
- `Makefile` (common in Go projects)
- Presence of `.go` files

### Discovery

Use `<leader>?` to see all available keymaps for your current context. The which-key plugin will show only relevant mappings based on your current project type and file.

## Tmux Integration

The configuration includes seamless tmux integration:

- **Window Navigation**: `Ctrl+h/j/k/l` works across Neovim windows and tmux panes
- **Consistent Experience**: Same navigation keys whether inside Neovim or tmux
- **Smart Switching**: Automatically detects tmux context and routes commands appropriately

## Customization

### Adding New Languages

1. Create a new plugin file: `nvim/lua/plugins/lang-{language}.lua`
2. Add detection logic for your language
3. Use FileType autocmds to conditionally load mappings
4. Follow the established pattern: `<leader>c{l}` for language-specific operations

### Modifying Existing Mappings

- **Universal mappings**: Edit `nvim/lua/plugins/which-key.lua`
- **Non-leader mappings**: Edit `nvim/lua/config/keymaps.lua`
- **Language-specific**: Edit the respective language plugin file

The configuration is designed to be discoverable, consistent, and context-aware, ensuring you always have the right tools available for your current project type.
