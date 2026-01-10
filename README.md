# Dotfiles Configuration

Modular dotfiles setup managed by [chezmoi](https://www.chezmoi.io/). Works across macOS, Arch Linux, and Debian/Ubuntu with automatic platform detection.

## Applications

-   [Alacritty](./docs/alacritty.md)
-   [Hyprland](./docs/hyprland.md) (Linux only)
-   [Neovim](./docs/neovim.md)
-   [pgcli](./docs/pgcli.md)
-   [tmux](./docs/tmux.md)
-   [Waybar](./docs/waybar.md) (Linux only)

See [Glossary of Files](./docs/glossary.md) for complete file reference.

## Quick Installation

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/asarchami/dotfiles/chezmoi/install.sh)"
```

This will:
1. Install Homebrew (if needed)
2. Install chezmoi
3. Clone this repository to `~/.local/share/chezmoi`
4. Initialize chezmoi

After installation, apply your dotfiles:

```sh
chezmoi apply
```

## Dependency Installation

Dependencies are installed automatically via `run_once_*` scripts when you run `chezmoi apply`. The system detects your platform and installs packages accordingly:

### Automatic Installation

**Core tools** (installed on all systems):
- Neovim, tmux, fzf, ripgrep, fd, eza, lazygit
- Node.js/npm (for Neovim LSP)
- Lua/LuaRocks (for Neovim plugins)
- JetBrainsMono Nerd Font

**Application-specific dependencies** (installed only if you apply that config):
- **tmux**: Terminal multiplexer
- **yazi**: File manager + media tools (ffmpeg, imagemagick, etc.)
- **Hyprland** (Arch Linux only): Wayland compositor + ecosystem (waybar, wofi, kanshi, etc.)
- **fish**: Oh My Fish framework

### Platform Support

- **macOS**: Uses Homebrew
- **Arch Linux**: Uses yay/pacman (installs yay if needed)
- **Debian/Ubuntu**: Uses Homebrew (Linuxbrew)

### Manual Installation

If automatic installation fails or you prefer manual control:

**macOS/Debian/Ubuntu:**
```sh
brew install neovim tmux fzf ripgrep fd eza lazygit
```

**Arch Linux:**
```sh
yay -S neovim tmux fzf ripgrep fd eza lazygit nodejs npm lua luarocks
```

For Hyprland dependencies on Arch, see [Hyprland docs](./docs/hyprland.md).

## Multi-Device Setup

Configurations automatically adapt based on:
- **Hostname**: `cachyos-desktop` (3 monitors), `cachyos-laptop` (dock/undock switching)
- **OS**: Linux vs macOS
- **Installed software**: Only applies configs for installed apps

### Setup on New Device

```sh
# Option 1: Quick setup (recommended)
bash -c "$(curl -fsSL https://raw.githubusercontent.com/asarchami/dotfiles/chezmoi/install.sh)"

# Option 2: Manual setup
brew install chezmoi
chezmoi init https://github.com/asarchami/dotfiles.git
chezmoi diff      # Preview changes
chezmoi apply     # Apply configurations
```

### Sync Changes

```sh
# Pull and apply updates
cd ~/.local/share/chezmoi
git pull
chezmoi apply

# Make and push changes
cd ~/.local/share/chezmoi
nvim dot_config/tmux/tmux.conf
chezmoi apply
git add .
git commit -m "Update tmux config"
git push
```

## Useful Commands

```sh
chezmoi status           # Show files that will change
chezmoi diff             # Show exact differences
chezmoi apply            # Apply all changes
chezmoi apply -v         # Apply with verbose output
chezmoi apply --dry-run  # Preview without applying
chezmoi data             # Show template data (hostname, OS, etc.)
chezmoi doctor           # Check for issues
```

## Troubleshooting

**Config changed since last apply:**
```sh
chezmoi apply --force
```

**Wrong config applied (check hostname):**
```sh
chezmoi data | grep hostname
```

**Hyprland monitor issues (laptop):**
```sh
pkill kanshi && kanshi &
hyprctl monitors
```

## Why chezmoi?

- **Cross-platform**: Works on macOS, Linux with automatic adaptation
- **Modular**: Each app manages its own dependencies
- **Selective**: Apply only the configs you need per machine
- **Templating**: Device-specific configurations using Go templates
- **Idempotent**: Safe to run multiple times
