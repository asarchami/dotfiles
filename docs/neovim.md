# Neovim Configuration

## Features

- **Modular Structure**: Organized plugin architecture using Lazy.nvim
- **Intelligent Language Support**: Python and Go plugins only load when working on relevant projects
- **Project Detection**: Automatically detects project type and loads appropriate tools
- **Dark Theme**: TokyoNight color scheme with excellent syntax highlighting
- **Consolidated Keymaps**: All key mappings in a single file for easy management
- **Which-Key Integration**: Discoverable key bindings with helpful descriptions
- **Git Integration**: Lazygit, GitSigns, and comprehensive git workflow tools
- **Debugging**: DAP support for Python and Go with visual debugging interface
- **Testing**: Integrated testing frameworks for both Python (pytest) and Go
- **LSP**: Language servers with auto-completion, formatting, and linting
- **Text Manipulation**: Powerful surround operations for quotes, brackets, and tags
- **File Navigation**: Telescope fuzzy finder and Neo-tree file explorer
- **Tmux Integration**: Seamless navigation between Neovim and tmux panes

## Smart Language Loading
- **Python Support**: Only loads when Python 3 is installed AND you're working on a Python project  
- **Go Support**: Only loads when Go is installed AND you're working on a Go project
- **Automatic Detection**: Language tools are automatically excluded if the language runtime isn't available
- **Core Tools**: Always available regardless of project type
- **Performance**: Faster startup by not loading unnecessary plugins

## Smart Project Detection

The configuration automatically detects your project type based on:

### Python Projects
- `requirements.txt`, `pyproject.toml`, `setup.py`, `setup.cfg`
- `Pipfile`, `poetry.lock`, `pyrightconfig.json`
- `.python-version`, `conda.yaml`, `environment.yml`
- Presence of `.py` files

### Go Projects  
- `go.mod`, `go.sum`, `go.work`, `main.go`
- `Makefile` (common in Go projects)
- Presence of `.go` files

### General Projects
- When no specific language indicators are found
- Only core plugins and general language servers load

## Key Mappings

All key mappings are documented in [KEYMAPS.md](KEYMAPS.md). The configuration features:

- **Universal Operations**: Always available (File, Git, Buffer, Window, Search, Core LSP)
- **Smart Context**: Language-specific mappings only appear when relevant
- **Discoverable**: Use `<leader>?` to see available keymaps for your current context
- **Consistent**: Same navigation works across Neovim windows and tmux panes

**Leader Key**: `<Space>`

### Keymap Organization

The keymap configuration is organized into two main files:

- **`lua/config/keymaps.lua`**: Non-leader keymaps (Ctrl, Alt, Shift combinations, telescope file browser actions)
- **`lua/plugins/which-key.lua`**: All leader-based mappings with discoverable groups and descriptions

For complete keymaps reference, see **[KEYMAPS.md](KEYMAPS.md)**.

## Language Support

### Python Development (Conditional Loading)
**Loads only when:**
- Python 3 is installed on the system
- Working in a detected Python project

**Features:**
- **LSP**: Pyright language server with type checking
- **Formatting**: Black and isort integration
- **Linting**: Ruff and Pylint support
- **Testing**: pytest integration with Neotest
- **Debugging**: debugpy with visual debugging interface
- **Virtual Environments**: Automatic detection and selection
- **REPL**: Iron.nvim for interactive Python sessions
- **Project Management**: Automatic project detection

### Go Development (Conditional Loading)
**Loads only when:**
- Go is installed on the system
- Working in a detected Go project

**If Go is not installed:**
- Go plugins are completely skipped
- No Go LSP servers or tools are installed via Mason
- Zero impact on startup time or functionality

**Features:**
- **LSP**: gopls language server
- **Formatting**: gofumpt and goimports
- **Testing**: Go test integration with coverage
- **Debugging**: Delve debugger integration
- **Build Tools**: Go build, run, and install commands
- **Code Generation**: Struct tags, interface implementation
- **Project Management**: go.mod support

### Core Development (Always Available)
- **LSP**: Lua, Bash, JSON, YAML, Docker, Markdown
- **Git**: Full git integration with Lazygit
- **File Management**: Telescope and Neo-tree
- **UI**: Beautiful interface with statusline and dashboard

## Customization

### Adding Languages
1. Create a new `lang-{language}.lua` file in `nvim/lua/plugins/`
2. Add detection logic to `project-detection.lua`
3. Use conditional loading with `cond` functions

### Modifying Keymaps
Edit `nvim/lua/config/keymaps.lua` to add or modify key mappings. The file is well-organized with sections for different functionality.

### Project Detection
Modify `nvim/lua/config/project-detection.lua` to:
- Add new file patterns for project detection
- Adjust detection logic
- Add support for new languages

## Troubleshooting

### Language Support Issues
```bash
# Check if languages are detected
:lua print(require("config.project-detection").get_project_type())

# Check if languages are available
:lua print(require("config.project-detection").is_language_available("python"))
:lua print(require("config.project-detection").is_language_available("go"))
```

### LSP Issues
- Run `:Mason` to check LSP server installation
- Use `:LspInfo` to diagnose language server problems
- Check `:checkhealth` for overall system health

### Plugin Issues
- Run `:Lazy` to manage plugins
- Use `:Lazy sync` to update all plugins
- Check `:Lazy log` for installation errors
