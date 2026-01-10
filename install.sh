#!/bin/bash

# Bootstrap script for dotfiles setup
# Works on macOS, Arch Linux, and other Linux distros
# Installs chezmoi and clones the dotfiles repository

set -e

# --- Configuration ---
REPO_URL="https://github.com/asarchami/dotfiles.git"
DEST_DIR="$HOME/.local/share/chezmoi"

# --- Helper Functions ---

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Detect OS and package manager
detect_system() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif command_exists pacman && [ -f /etc/arch-release ]; then
        echo "arch"
    else
        echo "linux-other"
    fi
}

# --- Installation Functions ---

install_homebrew() {
    if ! command_exists brew; then
        echo "📦 Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Configure Homebrew in current session
        if [ -f /home/linuxbrew/.linuxbrew/bin/brew ]; then
            eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        elif [ -f /opt/homebrew/bin/brew ]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
    else
        echo "✅ Homebrew is already installed."
    fi
}

install_yay() {
    if command_exists yay; then
        echo "✅ yay is already installed."
        return 0
    fi
    
    echo "📦 Installing yay AUR helper..."
    
    # Check if we can install dependencies
    if ! command_exists pacman; then
        echo "❌ Error: pacman not found. Cannot install yay."
        exit 1
    fi
    
    # Install base-devel and git if needed
    echo "Installing yay dependencies..."
    sudo pacman -S --needed --noconfirm git base-devel
    
    # Clone and build yay
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ~
    rm -rf /tmp/yay
    
    echo "✅ yay installed successfully."
}

install_chezmoi() {
    if command_exists chezmoi; then
        echo "✅ chezmoi is already installed."
        return 0
    fi
    
    local system=$(detect_system)
    
    case "$system" in
        macos)
            echo "📦 Installing chezmoi via Homebrew..."
            brew install chezmoi
            ;;
        arch)
            echo "📦 Installing chezmoi via yay..."
            if ! command_exists yay; then
                install_yay
            fi
            yay -S --needed --noconfirm chezmoi
            ;;
        linux-other)
            echo "📦 Installing chezmoi via Homebrew (Linuxbrew)..."
            install_homebrew
            brew install chezmoi
            ;;
    esac
}

install_git() {
    if command_exists git; then
        echo "✅ git is already installed."
        return 0
    fi
    
    local system=$(detect_system)
    
    case "$system" in
        macos)
            echo "📦 Installing git via Homebrew..."
            brew install git
            ;;
        arch)
            echo "📦 Installing git via pacman..."
            if ! command_exists pacman; then
                echo "❌ Error: pacman not found. Please install git manually."
                exit 1
            fi
            sudo pacman -S --needed --noconfirm git
            ;;
        linux-other)
            echo "📦 Installing git via Homebrew (Linuxbrew)..."
            install_homebrew
            brew install git
            ;;
    esac
}

clone_dotfiles_repo() {
    if [ -d "$DEST_DIR" ]; then
        echo "✅ Dotfiles repository already exists at $DEST_DIR"
        return 0
    fi
    
    echo "📦 Cloning dotfiles repository to $DEST_DIR..."
    git clone "$REPO_URL" "$DEST_DIR"
}

initialize_chezmoi() {
    echo "⚙️  Initializing chezmoi..."
    chezmoi init --source "$DEST_DIR"
}

# --- Main Function ---

main() {
    echo "🚀 Starting dotfiles setup..."
    echo ""
    
    local system=$(detect_system)
    echo "📋 Detected system: $system"
    echo ""
    
    # Install prerequisites based on system
    case "$system" in
        macos)
            install_homebrew
            ;;
        arch)
            # For Arch, we'll install yay if needed when installing chezmoi
            ;;
        linux-other)
            install_homebrew
            ;;
    esac
    
    install_git
    install_chezmoi
    clone_dotfiles_repo
    initialize_chezmoi
    
    echo ""
    echo "✅ Setup complete!"
    echo ""
    echo "📝 Next steps:"
    echo "   1. Run 'chezmoi apply' to apply your dotfiles"
    echo "   2. Dependencies will be installed automatically via run_once_* scripts"
    echo "   3. See ~/.local/share/chezmoi/README.md for more information"
}

# --- Run Script ---

main
