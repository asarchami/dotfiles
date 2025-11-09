#!/bin/bash

# This script sets up the dotfiles repository by cloning it and initializing chezmoi.
# It is designed to be run from a remote URL.

set -e

# --- Configuration ---
REPO_URL="https://github.com/asarchami/dotfiles.git"
DEST_DIR="$HOME/.local/share/chezmoi"

# --- Helper Functions ---

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# --- Installation Functions ---

install_homebrew() {
    if ! command_exists brew; then
        echo "Homebrew not found. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        echo "Homebrew is already installed."
    fi
}

configure_shell_for_homebrew() {
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
}

install_chezmoi() {
    if ! command_exists chezmoi; then
        echo "chezmoi not found. Installing chezmoi with Homebrew..."
        brew install chezmoi
    else
        echo "chezmoi is already installed."
    fi
}

install_direnv() {
    if ! command_exists direnv; then
        echo "direnv not found. Installing direnv with Homebrew..."
        brew install direnv
    else
        echo "direnv is already installed."
    fi
}

install_git() {
    if ! command_exists git; then
        echo "git not found. Installing git with Homebrew..."
        brew install git
    else
        echo "git is already installed."
    fi
}

install_yazi_and_deps() {
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
}

install_nerd_font() {
    FONT_DIR="$HOME/.local/share/fonts"
    FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip"
    FONT_ZIP="JetBrainsMono.zip"

    echo "Installing JetBrains Mono Nerd Font..."

    mkdir -p "$FONT_DIR"

    if command_exists curl; then
        curl -L "$FONT_URL" -o "$FONT_DIR/$FONT_ZIP"
    elif command_exists wget; then
        wget -O "$FONT_DIR/$FONT_ZIP" "$FONT_URL"
    else
        echo "Neither curl nor wget found. Please install them to download the font."
        return 1
    fi

    if ! command_exists unzip; then
        echo "unzip not found. Please install unzip to extract the font."
        return 1
    fi

    unzip -o "$FONT_DIR/$FONT_ZIP" -d "$FONT_DIR"
    rm "$FONT_DIR/$FONT_ZIP"

    fc-cache -fv
    echo "JetBrains Mono Nerd Font installed."
}

clone_dotfiles_repo() {
    if [ ! -d "$DEST_DIR" ]; then
        echo "Cloning dotfiles repository to $DEST_DIR..."
        git clone "$REPO_URL" "$DEST_DIR"
    else
        echo "Dotfiles repository already exists at "$DEST_DIR"."
    fi
}

initialize_chezmoi() {
    echo "Initializing chezmoi..."
    chezmoi init --source "$DEST_DIR"
}

# --- Main Function ---

main() {
    install_homebrew
    configure_shell_for_homebrew
    install_chezmoi
    install_direnv
    install_git
    install_yazi_and_deps
    install_nerd_font
    clone_dotfiles_repo
    initialize_chezmoi
    echo "Setup complete. You can now use 'chezmoi apply' to apply your dotfiles."
}

# --- Run Script ---

main
