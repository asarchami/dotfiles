#!/bin/bash

# This script installs tmux and its dependencies
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

echo "🚀 Installing tmux dependencies..."

# Install tmux
# Package names: brew=tmux, arch=tmux
install_package "tmux" "tmux" "tmux"

echo "✅ Tmux dependencies installation complete!"
