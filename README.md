# Dotfiles Configuration

This repository contains a comprehensive, modular dotfiles setup for various applications, managed by [chezmoi](https://www.chezmoi.io/).

## Overview

This setup is designed to be modular and easy to manage. Each application's configuration is documented in its own file, providing a clear and organized structure. The configurations are optimized for a development workflow, with a focus on performance and usability.

## Applications

The following applications are configured in this repository:

-   [Alacritty](./docs/alacritty.md)
-   [Hyprland](./docs/hyprland.md)
-   [Neovim](./docs/neovim.md)
-   [pgcli](./docs/pgcli.md)
-   [tmux](./docs/tmux.md)
-   [Waybar](./docs/waybar.md)

For a detailed list of all configuration files and their purposes, please see the [Glossary of Files](./docs/glossary.md).

## Installation

This entire dotfiles configuration is managed by [chezmoi](https://www.chezmoi.io/), a powerful and flexible dotfile manager that helps you manage your dotfiles across multiple machines.

### Prerequisites

-   `git`
-   [Homebrew](https://brew.sh/) (for package management)
-   `chezmoi` (will be installed by the setup script)

### Required Packages

#### For Hyprland (Linux Only)

**Core Hyprland:**
- `hyprland` - Wayland compositor
- `hypridle` - Idle daemon
- `hyprlock` - Screen lock
- `hyprshot` - Screenshot tool

**UI Components:**
- `waybar` - Status bar
- `mako` - Notification daemon
- `wofi` - Application launcher
- `wlogout` - Logout menu

**Terminal & Apps:**
- `alacritty` - Primary terminal emulator
- `foot` - Secondary terminal emulator
- `yazi` - TUI file manager

**System Utilities:**
- `pavucontrol` - Audio volume control
- `polkit-kde-agent` or `polkit-gnome` - Authentication agent
- `kanshi` - Dynamic monitor management (laptop only)

**Install on Arch-based systems:**
```sh
sudo pacman -S hyprland hypridle hyprlock hyprshot waybar mako wofi wlogout \
               alacritty foot yazi pavucontrol polkit-kde-agent kanshi
```

#### For All Systems

**Development Tools:**
- `tmux` - Terminal multiplexer
- `neovim` - Text editor
- `fzf` - Fuzzy finder
- `ripgrep` - Fast grep alternative
- `fd` - Fast find alternative
- `eza` - Modern ls replacement
- `lazygit` - Git TUI

**Install via Homebrew (macOS/Linux):**
```sh
brew install tmux neovim fzf ripgrep fd eza lazygit
```

### Installation Steps

To get started, run the following command in your terminal. It will download and run the installation script, which will:

1.  Install Homebrew (if not already installed).
2.  Install `chezmoi` (if not already installed).
3.  Clone this dotfiles repository to `~/.local/share/chezmoi`.
4.  Initialize `chezmoi`.

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/asarchami/dotfiles/chezmoi/install.sh)"
```

After the script completes, your dotfiles will be ready to manage with `chezmoi`. You can then apply the configurations you want. For example:

```sh
# Apply all dotfiles
chezmoi apply

# Apply only the tmux configuration
chezmoi apply ~/.config/tmux
```

### Conditional Configuration Application

This dotfiles repository includes configurations for multiple operating systems and applications. Configurations are automatically applied only when relevant:

**Automatic OS-based filtering:**
- Linux-specific configs (Hyprland, Waybar, Wofi, Foot) are automatically ignored on macOS
- This is handled via `.chezmoiignore` templates in the root directory

**Automatic software detection:**
- Each module directory (hypr, waybar, wofi, foot, yazi) contains a `.chezmoiignore` file
- These files use chezmoi templates with `lookPath` to check if the software is installed
- If the software is not installed, the entire module directory is ignored
- No manual steps needed - just run `chezmoi apply` and it will only apply configs for installed software

### Updating Your Dotfiles

To get the latest changes from this repository, simply run:

```sh
cd ~/.local/share/chezmoi
git pull
chezmoi apply
```

The `chezmoi apply` command ensures that your dotfiles are in the correct state and applies any new changes.

## Using Across Multiple Devices

This dotfiles repository is designed to work seamlessly across different devices with intelligent configuration switching. The setup currently supports:

- **PC (cachyos-desktop)**: Desktop with 3 external monitors (DP-1, DP-2, DP-3)
- **Dell Laptop (cachyos-laptop)**: Laptop with dynamic monitor switching (dock/undock support)
- **MacBook Pro**: macOS configuration (Linux-specific configs automatically ignored)

### Initial Setup on a New Device

#### Option 1: Quick Setup (Recommended)

Run the installation script which handles everything automatically:

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/asarchami/dotfiles/chezmoi/install.sh)"
```

#### Option 2: Manual Setup

If you prefer manual installation:

```sh
# Install chezmoi
brew install chezmoi

# Initialize chezmoi with your dotfiles repository
chezmoi init https://github.com/asarchami/dotfiles.git

# Preview what changes will be made
chezmoi diff

# Apply the dotfiles
chezmoi apply
```

### Device-Specific Configurations

The repository uses chezmoi's templating to automatically apply the correct configuration based on:

1. **Hostname**: Different configs for `cachyos-desktop`, `cachyos-laptop`, etc.
2. **Operating System**: Linux vs macOS
3. **Installed Software**: Only applies configs for installed applications

#### PC (cachyos-desktop)

When you run `chezmoi apply` on your PC, you'll get:
- Static 3-monitor Hyprland configuration
- All development tools (tmux, neovim, etc.)
- No kanshi (not needed for static setup)

#### Laptop (cachyos-laptop)

When you run `chezmoi apply` on your laptop, you'll get:
- Dynamic monitor management via kanshi
- Automatic laptop screen disable when docked
- Automatic laptop screen enable when undocked
- All development tools

**Kanshi Profiles:**
- **Docked**: 3 external monitors (DP-2, DP-3, DP-5), laptop screen OFF
- **Laptop-only**: Just eDP-1 (laptop screen)
- **Laptop + external**: eDP-1 + 1 external monitor

#### MacBook Pro (macOS)

When you run `chezmoi apply` on macOS, you'll get:
- macOS-compatible tools (tmux, neovim, alacritty, etc.)
- Linux-specific configs automatically skipped (Hyprland, Waybar, Wofi, Foot)
- Development environment configurations

### Making Changes

#### On Any Device

To modify your dotfiles:

```sh
# Navigate to chezmoi source directory
cd ~/.local/share/chezmoi

# Edit the file you want to change
nvim dot_config/tmux/tmux.conf

# Preview changes before applying
chezmoi diff

# Apply changes to your home directory
chezmoi apply

# Commit and push changes (if you have write access)
git add .
git commit -m "Update tmux configuration"
git push
```

#### Device-Specific Changes

If you need to make a change that only applies to one device:

**Example: Laptop-only configuration**

```sh
cd ~/.local/share/chezmoi

# Edit a template file
nvim dot_config/kanshi/config.tmpl

# The template uses conditionals:
# {{- if eq .chezmoi.hostname "cachyos-laptop" -}}
#   laptop-specific config
# {{- end -}}

# Apply and test
chezmoi apply
```

### Syncing Changes Across Devices

#### From One Device to Others

After making changes on one device:

```sh
# On the device where you made changes
cd ~/.local/share/chezmoi
git add .
git commit -m "Describe your changes"
git push
```

Then on other devices:

```sh
# On other devices
cd ~/.local/share/chezmoi
git pull
chezmoi apply
```

#### Checking What Changed

Before applying updates:

```sh
# See what files changed
cd ~/.local/share/chezmoi
git log --oneline -5

# Preview what will be applied
chezmoi diff

# Apply only if you're satisfied
chezmoi apply
```

### Useful Chezmoi Commands

```sh
# Check current state
chezmoi status           # Show files that will change
chezmoi diff             # Show exact differences

# Apply configurations
chezmoi apply            # Apply all changes
chezmoi apply -v         # Apply with verbose output
chezmoi apply --dry-run  # Simulate without making changes
chezmoi apply --force    # Force overwrite modified files

# Manage specific files
chezmoi apply ~/.config/tmux  # Apply only tmux config
chezmoi edit ~/.config/nvim   # Edit nvim config in chezmoi

# Debug and information
chezmoi data             # Show template data (hostname, OS, etc.)
chezmoi doctor           # Check for potential issues
chezmoi cd               # Navigate to chezmoi source directory

# Update from repository
cd ~/.local/share/chezmoi
git pull
chezmoi apply
```

### Troubleshooting

#### Config Changed Since Last Apply

If you see "file has changed since chezmoi last wrote it":

```sh
# Force apply to overwrite local changes
chezmoi apply --force

# Or re-add the file to chezmoi if you want to keep local changes
chezmoi add ~/.config/file-that-changed
```

#### Wrong Config Applied

Check your hostname matches expected values:

```sh
chezmoi data | grep hostname
# Should show: "cachyos-desktop" or "cachyos-laptop" or your Mac hostname
```

If hostname is different, either:
1. Update templates to include your hostname
2. Or change your hostname to match template conditions

#### Hyprland Monitor Issues (Laptop)

If monitors aren't switching correctly:

```sh
# Check if kanshi is running
pgrep kanshi

# Restart kanshi
pkill kanshi
kanshi &

# Check monitor status
hyprctl monitors

# Manually reload kanshi config
pkill -HUP kanshi
```

## Why chezmoi?

`chezmoi` is used to manage these dotfiles for several key reasons:

-   **Declarative Management**: Define the desired state of your dotfiles, and `chezmoi` makes it so.
-   **Idempotent**: Apply your dotfiles multiple times without unexpected side effects.
-   **Cross-Platform**: Works seamlessly across different operating systems (Linux, macOS).
-   **Templating**: Use Go templates to customize dotfiles for different machines or environments.
-   **Machine-Specific Configs**: Different configurations per device without maintaining separate branches.
-   **Dynamic Monitor Management**: Intelligent switching between docked/undocked laptop configurations.
-   **Security**: Manage sensitive information securely with integration with password managers.
-   **Simplicity**: Keeps your dotfiles organized and easy to deploy.