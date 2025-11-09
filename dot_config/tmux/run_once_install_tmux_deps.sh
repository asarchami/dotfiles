#!/bin/bash

# This script installs tmux using Homebrew.
# It checks if tmux is already installed and only installs it if it's not present.

# --- Configuration ---
# List of packages to ensure are installed.
packages=(
    "tmux"
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

echo "Checking and installing tmux with Homebrew..."

for package in "${packages[@]}"; do
    # For tmux, the command to check is simply 'tmux'
    cmd_to_check="$package"

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

echo "All specified tmux dependencies have been checked."
