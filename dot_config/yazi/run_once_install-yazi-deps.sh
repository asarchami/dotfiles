#!/bin/bash

# This script installs yazi and its dependencies
# Works across macOS (Homebrew), Arch Linux (yay/pacman), and other Linux (Linuxbrew)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHEZMOI_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source helper functions
if [ -f "$CHEZMOI_DIR/.install-helpers.sh" ]; then
    source "$CHEZMOI_DIR/.install-helpers.sh"
else
    echo "Error: Helper functions not found at $CHEZMOI_DIR/.install-helpers.sh"
    exit 1
fi

echo "🚀 Installing yazi and its dependencies..."

# Core yazi
install_package "yazi" "yazi" "yazi"

# File utilities
install_package "fd" "fd" "fd"
install_package "ripgrep" "ripgrep" "rg"
install_package "fzf" "fzf" "fzf"
install_package "zoxide" "zoxide" "zoxide"

# Media tools
install_package "ffmpeg" "ffmpeg" "ffmpeg"
install_package "sevenzip" "p7zip" "7z"
install_package "jq" "jq" "jq"
install_package "poppler" "poppler" "pdfinfo"
install_package "imagemagick" "imagemagick" "convert"
install_package "resvg" "resvg" "resvg"

# Fonts (GUI only)
PKG_MANAGER=$(detect_package_manager)
if [[ "$PKG_MANAGER" == "brew" ]]; then
    install_package "font-symbols-only-nerd-font" "" ""
elif [[ "$PKG_MANAGER" == "yay" ]] || [[ "$PKG_MANAGER" == "pacman" ]]; then
    install_package "" "ttf-nerd-fonts-symbols" ""
fi

echo "✅ Yazi dependencies installation complete!"
