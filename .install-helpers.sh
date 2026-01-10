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
# Usage: install_package "brew_name" "arch_name" "cmd_check"
# Note: For Debian/Ubuntu and other Linux, we use Homebrew (linuxbrew) for simplicity
install_package() {
    local brew_name="$1"
    local arch_name="$2"
    local cmd_check="$3"
    
    # Check if already installed
    if [ -n "$cmd_check" ] && command_exists "$cmd_check"; then
        echo "✅ $brew_name is already installed."
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
