#!/bin/bash

# This script sets up the dotfiles repository by cloning it and initializing chezmoi.
# It is designed to be run from a remote URL.

set -e

# --- Configuration ---
REPO_URL="https://github.com/asarchami/dotfiles.git"
DEST_DIR="$HOME/.local/share/chezmoi"

# --- Script ---

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

# Clone the dotfiles repository if it doesn't exist
if [ ! -d "$DEST_DIR" ]; then
    echo "Cloning dotfiles repository to $DEST_DIR..."
    git clone "$REPO_URL" "$DEST_DIR"
else
    echo "Dotfiles repository already exists at $DEST_DIR."
fi

# Initialize chezmoi
echo "Initializing chezmoi..."
chezmoi init --source "$DEST_DIR"

echo "Setup complete. You can now use 'chezmoi apply' to apply your dotfiles."