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

# Add Homebrew to PATH and shell profile
echo "Configuring shell for Homebrew..."
if [ -f /home/linuxbrew/.linuxbrew/bin/brew ]; then # Linux
    BREW_PATH="/home/linuxbrew/.linuxbrew/bin/brew"
elif [ -f /opt/homebrew/bin/brew ]; then # macOS
    BREW_PATH="/opt/homebrew/bin/brew"
else
    BREW_PATH=""
fi

if [ -n "$BREW_PATH" ]; then
    eval "$($BREW_PATH shellenv)"
    
    SHELL_TYPE=$(basename "$SHELL")
    echo "Detected shell: $SHELL_TYPE"

    case "$SHELL_TYPE" in
    bash)
        PROFILE_FILE="$HOME/.bashrc"
        ;;
    zsh)
        PROFILE_FILE="$HOME/.zshrc"
        ;;
    fish)
        PROFILE_FILE="$HOME/.config/fish/config.fish"
        ;;
    *)
        echo "Unsupported shell: $SHELL_TYPE. Please add Homebrew to your shell's configuration file manually."
        PROFILE_FILE=""
        ;;
    esac

    if [ -n "$PROFILE_FILE" ]; then
        if [ "$SHELL_TYPE" = "fish" ]; then
            if ! grep -q "eval ($BREW_PATH shellenv)" "$PROFILE_FILE"; then
                echo "Adding Homebrew to $PROFILE_FILE"
                echo "eval ($BREW_PATH shellenv)" >> "$PROFILE_FILE"
            fi
        else
            if ! grep -q 'eval "$('$BREW_PATH' shellenv)"' "$PROFILE_FILE"; then
                echo "Adding Homebrew to $PROFILE_FILE"
                echo 'eval "$('$BREW_PATH' shellenv)"' >> "$PROFILE_FILE"
            fi
        fi
    fi
fi

# Install chezmoi using Homebrew if it's not installed
if ! command_exists chezmoi; then
    echo "chezmoi not found. Installing chezmoi with Homebrew..."
    brew install chezmoi
else
    echo "chezmoi is already installed."
fi

# Function to install JetBrains Mono Nerd Font
install_nerd_font() {
    echo "Installing JetBrains Mono Nerd Font..."
    if brew tap | grep -q "homebrew/cask-fonts"; then
        echo "homebrew/cask-fonts is already tapped."
    else
        brew tap homebrew/cask-fonts
    fi
    brew install --cask font-jetbrains-mono-nerd-font
}

# Install JetBrains Mono Nerd Font
install_nerd_font

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