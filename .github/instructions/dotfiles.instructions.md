# Chezmoi Dotfiles Repository Instructions

This is a dotfiles configuration repository managed by [chezmoi](https://www.chezmoi.io/), containing modular configurations for development tools and system applications.

## Repository Overview

**Purpose**: Manage and deploy consistent dotfiles across multiple machines using chezmoi's templating and OS-aware conditional application.

**Key Files**:
- `.chezmoiignore` - OS-based filtering (Linux vs macOS)
- `dot_config/` - Application configuration modules (alacritty, nvim, tmux, hypr, waybar, fish, etc.)
- `docs/` - Documentation for each application
- `install.sh` - Installation script for fresh setup
- `run_once_install_deps.sh` - One-time dependency installation

## When Making Changes

### Configuration Changes
1. **Modify configs in `dot_config/`** - Each subdirectory represents an application (e.g., `dot_config/nvim/`, `dot_config/tmux/`)
2. **Update documentation** - Add corresponding docs in `docs/` if adding new app configs
3. **Test with chezmoi** - Run `chezmoi diff` before applying changes
4. **Apply safely** - Use `chezmoi apply` to deploy changes

### Adding New Applications
1. Create new directory in `dot_config/` following naming convention
2. Add a `.chezmoiignore` file if software detection is needed (see existing modules)
3. Place configuration files inside
4. Document in `docs/` with setup instructions
5. Update README.md with application link

### OS-Specific Configurations
- Linux-specific configs (Hyprland, Waybar, Wofi, Foot) are handled via `.chezmoiignore` templates
- Use chezmoi `lookPath` to detect installed software and conditionally ignore modules
- Test on both Linux and macOS to ensure proper filtering

## Directory Structure
```
.
├── dot_config/          # Application configs (chezmoi format: "dot_" prefix → hidden files)
│   ├── alacritty/       # Terminal emulator config
│   ├── fish/            # Shell configuration (not yet documented)
│   ├── foot/            # Terminal (Linux only)
│   ├── hypr/            # Wayland compositor (Linux only)
│   ├── nvim/            # Neovim editor
│   ├── pgcli/           # PostgreSQL CLI
│   ├── tmux/            # Terminal multiplexer
│   ├── waybar/          # Status bar (Linux only)
│   ├── wofi/            # Application launcher (Linux only)
│   └── yazi/            # File manager (not yet documented)
├── docs/                # Application-specific documentation
├── install.sh           # Bootstrap script
├── run_once_install_deps.sh  # Dependency installer
└── README.md            # Main documentation
```

## Common Tasks

### Checking configuration status
```bash
chezmoi status
chezmoi diff
```

### Applying configurations
```bash
chezmoi apply              # All configs
chezmoi apply ~/.config/tmux  # Specific app
```

### Updating from repository
```bash
git pull
chezmoi apply
```

### Testing changes safely
```bash
chezmoi diff          # Preview changes
chezmoi apply --dry-run  # Simulate without applying
```

## Important Notes

- Configurations are **declarative** - chezmoi ensures desired state
- Conditional application is **automatic** - no manual OS filtering needed
- Use **chezmoi templates** (Go template syntax) for machine/environment-specific configs
- Keep sensitive data out of dotfiles; use password managers with chezmoi integration if needed

## Git Workflow

**DO NOT commit changes unless explicitly asked.** Always:
1. Make file modifications as needed
2. Show the changes via `git diff` or by viewing modified files
3. Wait for explicit instruction to commit or push
4. Only commit when you receive a direct request like "commit these changes" or "push to main"

This ensures you have full control over what gets committed to the repository.
