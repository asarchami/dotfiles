#!/bin/bash

# Universal dependency installation script for core development tools
# Supports: macOS (Homebrew), Arch Linux (yay/pacman), other Linux (Linuxbrew)
#
# NOTE: Individual application configs have their own dependency installers:
#   - dot_config/tmux/run_once_install_tmux_deps.sh
#   - dot_config/yazi/run_once_install-yazi-deps.sh
#   - dot_config/hypr/run_once_install_hyprland_deps.sh (Linux Arch only)
#   - dot_config/fish/run_once_install_omf.sh
#
# This script installs only the core tools needed for Neovim development.

set -e

# --- Helper Functions ---

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

install_yay() {
    echo "📦 Installing yay AUR helper..."
    sudo pacman -S --needed --noconfirm git base-devel
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ~
    rm -rf /tmp/yay
}

install_linuxbrew() {
    echo "📦 Installing Linuxbrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for this session
    if [ -d "/home/linuxbrew/.linuxbrew" ]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
}

# Detect OS and package manager
detect_package_manager() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif command_exists yay; then
        echo "arch-yay"
    elif command_exists pacman && [ -f /etc/arch-release ]; then
        echo "arch-pacman"
    elif command_exists brew; then
        echo "linuxbrew"
    else
        echo "other-linux"
    fi
}

# Install a single package based on package manager
install_package() {
    local pkg_manager="$1"
    local brew_name="$2"
    local arch_name="$3"
    local cmd_check="$4"
    
    # Check if already installed
    if [ -n "$cmd_check" ] && command_exists "$cmd_check"; then
        echo "✅ $brew_name is already installed."
        return 0
    fi
    
    case "$pkg_manager" in
        macos|linuxbrew)
            echo "Installing $brew_name..."
            brew install "$brew_name" || echo "⚠️  Failed to install $brew_name"
            ;;
        arch-yay)
            echo "Installing $arch_name..."
            yay -S --needed --noconfirm "$arch_name" || echo "⚠️  Failed to install $arch_name"
            ;;
        arch-pacman)
            echo "Installing $arch_name..."
            sudo pacman -S --needed --noconfirm "$arch_name" || echo "⚠️  Failed to install $arch_name"
            ;;
    esac
}

# --- Pi coding agent (optional) ---

# Move the applied Pi configuration aside when the user declines the install.
# chezmoi copies dot_pi before this script runs, so a move is the only way to
# honor the choice. The move is reversible.
skip_pi_config() {
    if [ -d "$HOME/.pi/agent" ]; then
        local backup
        backup="$HOME/.pi/agent.skipped.$(date +%s)"
        mv "$HOME/.pi/agent" "$backup"
        echo "📝 Pi config moved to $backup"
        echo "   Restore it later with: mv \"$backup\" \"$HOME/.pi/agent\""
    fi
}

install_pi() {
    echo ""
    echo "🤖 Pi coding agent"
    echo ""

    if command_exists pi; then
        echo "✅ Pi is already installed."
        return 0
    fi

    if ! { : < /dev/tty; } 2>/dev/null; then
        echo "⚠️  Pi is not installed and no terminal is available."
        echo "   The Pi config is not applied on this machine."
        skip_pi_config
        return 0
    fi

    local answer=""
    printf "Pi is not installed. Install the latest Pi now? [y/N] "
    read -r answer < /dev/tty || answer=""

    case "$answer" in
        [yY]|[yY][eE][sS])
            if ! command_exists npm; then
                echo "⚠️  npm is not available. Pi cannot be installed."
                skip_pi_config
                return 0
            fi
            echo "📦 Installing Pi..."
            if ! npm install -g @earendil-works/pi-coding-agent; then
                echo "⚠️  Pi install failed. The Pi config stays in place."
                return 0
            fi
            if ! command_exists pi; then
                echo "⚠️  pi is installed, but not on PATH."
                echo "   Add this to PATH: $(npm config get prefix)/bin"
            fi
            ;;
        *)
            echo "⏭️  Pi install skipped."
            skip_pi_config
            ;;
    esac
}

# --- Main Script ---

echo "🚀 Starting core development tools installation..."
echo ""

PKG_MANAGER=$(detect_package_manager)
echo "📋 Detected system: $PKG_MANAGER"
echo ""

# Setup package manager if needed
case "$PKG_MANAGER" in
    arch-pacman)
        echo "⚙️  Setting up yay AUR helper..."
        install_yay
        PKG_MANAGER="arch-yay"
        ;;
    other-linux)
        echo "⚙️  Setting up Linuxbrew..."
        install_linuxbrew
        PKG_MANAGER="linuxbrew"
        ;;
esac

echo ""
echo "📦 Installing core development tools..."
echo ""

# Package definitions: brew_name, arch_name, command_to_check
# Format: install_package "$PKG_MANAGER" "brew_name" "arch_name" "cmd_check"

# Core development tools (Neovim dependencies)
install_package "$PKG_MANAGER" "neovim" "neovim" "nvim"
install_package "$PKG_MANAGER" "fzf" "fzf" "fzf"
install_package "$PKG_MANAGER" "ripgrep" "ripgrep" "rg"
install_package "$PKG_MANAGER" "fd" "fd" "fd"
install_package "$PKG_MANAGER" "eza" "eza" "eza"
install_package "$PKG_MANAGER" "lazygit" "lazygit" "lazygit"

# Node.js and npm (for Neovim LSP)
if [[ "$PKG_MANAGER" == "arch-yay" ]]; then
    install_package "$PKG_MANAGER" "node" "nodejs" "node"
    install_package "$PKG_MANAGER" "npm" "npm" "npm"
else
    install_package "$PKG_MANAGER" "node" "node" "node"
    # npm comes with node in Homebrew
fi

# Lua and LuaRocks (for Neovim plugins)
install_package "$PKG_MANAGER" "lua" "lua" "lua"
install_package "$PKG_MANAGER" "luarocks" "luarocks" "luarocks"

# Fonts (for terminal)
if [[ "$PKG_MANAGER" == "macos" || "$PKG_MANAGER" == "linuxbrew" ]]; then
    install_package "$PKG_MANAGER" "font-jetbrains-mono-nerd-font" "" ""
elif [[ "$PKG_MANAGER" == "arch-yay" ]]; then
    install_package "$PKG_MANAGER" "" "ttf-jetbrains-mono-nerd" ""
fi

echo ""
echo "✅ Core development dependencies installed!"
echo "📝 Note: Individual app configs have their own installers that run automatically"
echo ""

install_pi

# Post-installation notes
if command_exists fzf && [[ "$PKG_MANAGER" == "macos" || "$PKG_MANAGER" == "linuxbrew" ]]; then
    echo "📝 Note: fzf may require a post-installation step:"
    echo "   $(brew --prefix 2>/dev/null || echo '/home/linuxbrew/.linuxbrew')/opt/fzf/install"
    echo ""
fi

echo "🎉 Installation complete!"
