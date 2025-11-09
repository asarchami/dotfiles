#!/bin/bash

# This script installs dependencies for the Neovim configuration using Homebrew.
# It checks for each package and only installs it if it's not already present.

# --- Configuration ---
# List of packages to ensure are installed.
packages=(
    "neovim"
    "fzf"
    "ripgrep"
    "fd"
    "node"
    "npm"
    "luarocks"
    "lazygit"
)

# --- Script ---

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check for Homebrew
if ! command_exists brew; then
    echo "Homebrew not found. Please install Homebrew to continue."
    echo "See https://brew.sh/ for installation instructions."
    exit 1
fi

echo "Checking and installing Neovim dependencies with Homebrew..."

for package in "${packages[@]}"; do
    # Determine the command to check for. Usually the same as the package name.
    cmd_to_check="$package"
    if [ "$package" = "ripgrep" ]; then
        cmd_to_check="rg"
    elif [ "$package" = "neovim" ]; then
        cmd_to_check="nvim"
    fi

    if command_exists "$cmd_to_check"; then
        echo "✅ $package ($cmd_to_check) is already installed."
    else
        echo "Installing $package..."
        if brew install "$package"; then
            echo "✅ Successfully installed $package."
        else
            echo "❌ Failed to install $package. Please check Homebrew output."
            # Optional: exit on failure
            # exit 1
        fi
    fi
done

echo "All specified Neovim dependencies have been checked."

# Special post-install instructions if any
# For example, fzf requires a post-install step
if command_exists fzf; then
    echo "Note: fzf may require a post-installation step. If you haven't done so, you might need to run:"
    echo "$(brew --prefix)/opt/fzf/install"
fi
