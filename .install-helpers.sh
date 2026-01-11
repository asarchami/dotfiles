#!/bin/bash

# Shared helper functions for installation scripts
# Source this file in individual install scripts: source ~/.local/share/chezmoi/.install-helpers.sh

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

# Detect OS and package manager
detect_package_manager() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "brew"
    elif command_exists yay; then
        echo "yay"
    elif command_exists pacman && [ -f /etc/arch-release ]; then
        echo "pacman"
    elif command_exists brew; then
        echo "brew"
    else
        echo "unknown"
    fi
}

# Install a single package based on package manager
# Usage: install_package "brew_name" "arch_name" "debian_name" "cmd_check"
#   OR: install_package "brew_name" "arch_name" "cmd_check" (backward compatible)
# Note: For Debian/Ubuntu and other Linux, we use Homebrew (linuxbrew) for simplicity
install_package() {
    local brew_name="$1"
    local arch_name="$2"
    local param3="$3"
    local param4="$4"
    
    # Determine if using 3 or 4 parameter format
    local debian_name=""
    local cmd_check=""
    
    if [ -n "$param4" ]; then
        # 4 parameter format: brew, arch, debian, cmd
        debian_name="$param3"
        cmd_check="$param4"
    else
        # 3 parameter format: brew, arch, cmd (backward compatible)
        cmd_check="$param3"
    fi
    
    # Check if already installed
    if [ -n "$cmd_check" ] && command_exists "$cmd_check"; then
        local display_name="${brew_name:-$arch_name}"
        echo "✅ $display_name is already installed."
        return 0
    fi
    
    local pkg_manager=$(detect_package_manager)
    
    case "$pkg_manager" in
        brew)
            echo "Installing $brew_name..."
            brew install "$brew_name" 2>/dev/null || echo "⚠️  Failed to install $brew_name"
            ;;
        yay)
            echo "Installing $arch_name..."
            yay -S --needed --noconfirm "$arch_name" 2>/dev/null || echo "⚠️  Failed to install $arch_name"
            ;;
        pacman)
            echo "yay not found. Installing yay first..."
            install_yay
            echo "Installing $arch_name..."
            yay -S --needed --noconfirm "$arch_name" 2>/dev/null || echo "⚠️  Failed to install $arch_name"
            ;;
        *)
            echo "⚠️  Unknown package manager. Please install Homebrew first."
            echo "See https://brew.sh/ for installation instructions."
            ;;
    esac
}
