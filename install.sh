#!/bin/bash

# This script installs Homebrew and chezmoi.
# It is designed to be OS-independent (macOS and Linux).

set -e

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install Homebrew if it's not installed
if ! command_exists brew; then
    echo "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew is already installed."
fi

# Add Homebrew to PATH for the current script execution
# This is important for Linux where brew might not be in the default PATH
if [ -f /home/linuxbrew/.linuxbrew/bin/brew ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi
if [ -f /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Install chezmoi using Homebrew if it's not installed
if ! command_exists chezmoi; then
    echo "chezmoi not found. Installing chezmoi with Homebrew..."
    brew install chezmoi
else
    echo "chezmoi is already installed."
fi

echo "Installation of Homebrew and chezmoi is complete."
