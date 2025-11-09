#!/bin/bash

# This script installs yazi and its dependencies using Homebrew.

# --- Configuration ---
packages=(
    "yazi"
    "ffmpeg"
    "sevenzip"
    "jq"
    "poppler"
    "fd"
    "ripgrep"
    "fzf"
    "zoxide"
    "resvg"
    "imagemagick"
    "font-symbols-only-nerd-font"
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

echo "Checking and installing yazi and its dependencies with Homebrew..."

for package in "${packages[@]}"; do
    if brew list "$package" >/dev/null 2>&1; then
        echo "✅ $package is already installed."
    else
        echo "Installing $package..."
        if brew install "$package"; then
            echo "✅ Successfully installed $package."
        else
            echo "❌ Failed to install $package. Please check Homebrew output."
        fi
    fi
done

echo "All specified yazi dependencies have been checked."