#!/bin/bash

# This script installs Hyprland and its ecosystem dependencies
# Only runs on Linux systems

# Exit if not on Linux
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    echo "Skipping Hyprland installation - not on Linux"
    exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHEZMOI_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source helper functions
if [ -f "$CHEZMOI_DIR/.install-helpers.sh" ]; then
    source "$CHEZMOI_DIR/.install-helpers.sh"
else
    echo "Error: Helper functions not found at $CHEZMOI_DIR/.install-helpers.sh"
    exit 1
fi

PKG_MANAGER=$(detect_package_manager)

# Only install on Arch-based systems
if [[ "$PKG_MANAGER" != "yay" ]] && [[ "$PKG_MANAGER" != "pacman" ]]; then
    echo "Hyprland installation is currently only supported on Arch Linux"
    echo "For other distributions, please install Hyprland manually"
    exit 0
fi

echo "🚀 Installing Hyprland and ecosystem dependencies..."

# Core Hyprland
install_package "" "hyprland" "" "hyprctl"
install_package "" "hypridle" "" "hypridle"
install_package "" "hyprlock" "" "hyprlock"
install_package "" "hyprshot" "" "hyprshot"
install_package "" "kanshi" "" "kanshi"

# UI Components
install_package "" "waybar" "" "waybar"
install_package "" "mako" "" "mako"
install_package "" "wofi" "" "wofi"
install_package "" "wlogout" "" "wlogout"

# Terminal emulators
install_package "" "alacritty" "" "alacritty"
install_package "" "foot" "" "foot"

# System utilities
install_package "" "pavucontrol" "" "pavucontrol"
install_package "" "polkit-kde-agent" "" ""

echo "✅ Hyprland ecosystem installation complete!"
