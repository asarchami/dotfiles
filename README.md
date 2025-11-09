# Dotfiles Configuration

A comprehensive, modular dotfiles setup for Neovim and tmux with intelligent Python and Go development support that only loads when needed.

## Features

### Neovim Configuration
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

### tmux Configuration
- **Advanced tmux setup** with custom status line and key bindings
- **Plugin management** via TPM (Tmux Plugin Manager)
- **Session persistence** with tmux-resurrect plugin
- **Vim-style navigation** with intuitive pane switching
- **Custom prefix** (Ctrl-a instead of Ctrl-b)
- **Mouse support** and modern terminal features
- **F12 remote mode** for nested tmux sessions
- **Smart SSH detection** with different status colors for remote sessions
- **Complete keymaps reference**: See [tmux/KEYMAPS.md](tmux/KEYMAPS.md)

### Alacritty Configuration
- Modern, GPU-accelerated terminal emulator
- Tokyo Night color scheme matching Neovim theme
- JetBrains Mono font with proper powerline support
- Optimized key bindings for development workflow
- Tmux integration with split and navigation shortcuts
- Clipboard integration and search functionality

### Smart Language Loading
- **Python Support**: Only loads when Python 3 is installed AND you're working on a Python project  
- **Go Support**: Only loads when Go is installed AND you're working on a Go project
- **Automatic Detection**: Language tools are automatically excluded if the language runtime isn't available
- **Core Tools**: Always available regardless of project type
- **Performance**: Faster startup by not loading unnecessary plugins

## Installation

This entire dotfiles configuration is managed by [chezmoi](https://www.chezmoi.io/), a powerful and flexible dotfile manager that helps you manage your dotfiles across multiple machines.

### Prerequisites

-   `git`
-   [Homebrew](https://brew.sh/) (for package management)
-   `chezmoi` (will be installed by the setup script)

### One-Liner Setup

To get started, you can use the following one-liner to clone this repository and initialize `chezmoi`. This command will not apply any dotfiles, allowing you to choose which parts of the configuration you want to install.

```sh
git clone https://github.com/asarchami/dotfiles.git ~/.local/share/chezmoi && cd ~/.local/share/chezmoi && ./install.sh && chezmoi init
```

After running this command, you can inspect the dotfiles in `~/.local/share/chezmoi` and use `chezmoi apply` to apply the configurations you want. For example, to apply only the `tmux` configuration, you can run:

```sh
chezmoi apply ~/.config/tmux
```

### Manual Installation

If you prefer a manual installation, you can follow these steps:

1.  **Clone the repository:**
    ```sh
    git clone https://github.com/asarchami/dotfiles.git ~/.local/share/chezmoi
    ```

2.  **Install dependencies:**
    ```sh
    cd ~/.local/share/chezmoi && ./install.sh
    ```

3.  **Initialize `chezmoi`:**
    ```sh
    chezmoi init
    ```

4.  **Apply your desired dotfiles:**
    ```sh
    chezmoi apply
    ```

### Updating Your Dotfiles

To get the latest changes from this repository, simply run:

```sh
git pull
chezmoi apply
```

The `chezmoi apply` command ensures that your dotfiles are in the correct state and applies any new changes.

## Why chezmoi?

`chezmoi` is used to manage these dotfiles for several key reasons:

-   **Declarative Management**: Define the desired state of your dotfiles, and `chezmoi` makes it so.
-   **Idempotent**: Apply your dotfiles multiple times without unexpected side effects.
-   **Cross-Platform**: Works seamlessly across different operating systems (Linux, macOS).
-   **Templating**: Use Go templates to customize dotfiles for different machines or environments.
-   **Security**: Manage sensitive information securely with integration with password managers.
-   **Simplicity**: Keeps your dotfiles organized and easy to deploy.


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

## Alacritty Terminal Features

### Modern Terminal Experience
- **GPU Acceleration**: Hardware-accelerated rendering for smooth performance
- **True Color Support**: 24-bit color support for vivid themes
- **Cross-Platform**: Consistent experience across macOS and Linux
- **Minimal Input Latency**: Optimized for responsive typing

### Configuration Highlights
- **Tokyo Night Theme**: Matches your Neovim color scheme perfectly
- **JetBrains Mono Font**: Developer-optimized font with excellent readability
- **Smart Opacity**: 95% opacity for subtle transparency
- **Vi-Mode**: Navigate terminal history with Vim-like keybindings

### Key Bindings
```
Ctrl+Shift+C/V     # Copy/Paste
Ctrl+Shift+F/B     # Search forward/backward  
Ctrl+Shift+Space   # Toggle Vi mode
Ctrl+Plus/Minus    # Increase/decrease font size
Ctrl+Shift+N       # New Alacritty instance
F11                # Toggle fullscreen
```

### Tmux Integration
- **Smart Splits**: `Ctrl+Shift+D` for vertical, `Ctrl+Alt+D` for horizontal
- **Pane Navigation**: `Ctrl+Shift+H/L` and `Ctrl+Alt+K/J` for tmux pane switching
- **Seamless Workflow**: Optimized for development with tmux and Neovim

## Tmux Auto-Launch Configuration

To automatically start/connect to a tmux session called "main" every time you open a terminal, add one of the following to your shell configuration:

### For Zsh users (add to `~/.zshrc`):
```bash
# Auto-start tmux session "main" if not already in tmux
if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
    tmux has-session -t main 2>/dev/null || tmux new-session -d -s main
    exec tmux attach-session -t main
fi
```

### For Bash users (add to `~/.bashrc`):
```bash
# Auto-start tmux session "main" if not already in tmux
if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
    tmux has-session -t main 2>/dev/null || tmux new-session -d -s main
    exec tmux attach-session -t main
fi
```

### How It Works
- **Smart Detection**: Only activates in interactive shells, not in tmux sessions
- **Session Persistence**: Creates "main" session if it doesn't exist, connects if it does
- **Multiple Terminals**: All new terminal windows connect to the same tmux session
- **Safe**: Won't create nested tmux sessions or interfere with existing workflows

After adding this configuration:
1. **Reload your shell**: `source ~/.zshrc` or `source ~/.bashrc`
2. **Open a new terminal**: Will automatically connect to tmux "main" session
3. **Persistent workspace**: Your tmux session survives terminal restarts

### Tmux Plugin Management

The tmux configuration includes TPM (Tmux Plugin Manager) for easy plugin management:

**Install plugins**: `Ctrl-a + I` (after starting tmux)
**Update plugins**: `Ctrl-a + U`
**Uninstall plugins**: `Ctrl-a + Alt-u`

**Included plugins**:
- **tmux-resurrect**: Save/restore tmux sessions (`Ctrl-a + S` to save, `Ctrl-a + R` to restore)

**Key bindings**:
- **Prefix**: `Ctrl-a` (instead of default `Ctrl-b`)
- **Split panes**: `Ctrl-a + |` (vertical), `Ctrl-a + -` (horizontal)
- **Navigate panes**: `Ctrl-a + Ctrl-h/j/k/l`
- **Navigate windows**: `Ctrl-a + h/l` (vim-style left/right)
- **Resize panes**: `Ctrl-a + Ctrl-i/u/y/o`
- **Link window**: `Ctrl-a + w` (link from another session)
- **Remote mode**: `F12` (disable local tmux for nested sessions)

For complete tmux keymaps reference, see **[tmux/KEYMAPS.md](tmux/KEYMAPS.md)**.

## Dependencies

This setup uses [Homebrew](https://brew.sh/) to install all core dependencies. The `install.sh` script will automatically install Homebrew if it's not already present on your system (both macOS and Linux are supported).

**Python and Go are optional** - language-specific features will only load if the respective languages are installed.

### Core Dependencies (Managed by Homebrew)
- neovim
- tmux
- alacritty
- git
- lazygit
- fzf
- ripgrep
- fd
- tree-sitter
- node
- npm

### Language Dependencies (User-installed)
**Python 3** (optional):
- Install via your system package manager, pyenv, or Python.org
- pip3 recommended for additional tools

**Go** (optional):
- Install via your system package manager or golang.org

**JetBrains Mono Font** (recommended for Alacritty):
- Download from: https://www.jetbrains.com/lp/mono/
- Install system-wide for best Alacritty experience

## Installation Behavior

### Language Detection
The setup script will:
1. ✅ Install core dependencies
2. ⚠️ Check for Python 3 and warn if missing (but continue)
3. ⚠️ Check for Go and warn if missing (but continue)
4. 📦 Install appropriate language tools only if the language is available

### Plugin Loading
- **First Time**: Only core plugins load
- **Python Project**: Python plugins load automatically when you open a Python project
- **Go Project**: Go plugins load automatically when you open a Go project
- **Mixed Projects**: Appropriate plugins load based on the primary project type

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

## Performance Benefits

This smart loading approach provides:
- **Faster Startup**: Only loads plugins you actually need
- **Reduced Memory Usage**: Fewer plugins means less memory consumption
- **Cleaner Interface**: No language-specific keybindings cluttering other projects
- **Better Organization**: Each language environment is self-contained

## Support

This configuration is designed to be:
- **Intelligent**: Adapts to your project and available tools
- **Modular**: Easy to modify individual components
- **Documented**: Clear comments and organization
- **Extensible**: Simple to add new languages or tools
- **Safe**: Automatic backups prevent data loss
- **Efficient**: Only loads what you need, when you need it

For issues or customization help, refer to the individual plugin documentation or modify the configurations to suit your workflow. 