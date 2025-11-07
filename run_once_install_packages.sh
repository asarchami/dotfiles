#!/bin/bash
#
# This script is run by chezmoi only once.
# It installs Homebrew and all the packages.

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if a package is installed system-wide, not just via Homebrew
check_if_package_is_installed() {
    local package="$1"
    local cmd_to_check="$package"

    # Handle packages where the command is different from the package name
    case "$package" in
        ripgrep)
            cmd_to_check="rg"
            ;;
        neovim)
            cmd_to_check="nvim"
            ;;
        font-jetbrains-mono-nerd-font)
            # This is a cask, so we can't check for a command
            # We will rely on brew list to check if it's installed
            if brew list --cask "$package" >/dev/null 2>&1; then
                return 0
            else
                return 1
            fi
            ;;
    esac

    if command -v "$cmd_to_check" >/dev/null 2>&1; then
        return 0  # Package is installed
    else
        return 1  # Package is not installed
    fi
}

# Install a single brew package if not already installed
install_brew_package() {
    local package="$1"
    if check_if_package_is_installed "$package"; then
        print_info "$package is already installed (skipping)"
    else
        print_info "Installing $package..."
        brew install "$package"
        print_success "$package installed successfully"
    fi
}

install_homebrew() {
    # Check if Homebrew is installed
    if ! command -v brew >/dev/null 2>&1;
 then
        print_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        print_success "Homebrew installed successfully"

        # Add Homebrew to PATH for Linux
        if [[ "$(uname)" == "Linux" ]]; then
            print_info "Adding Homebrew to your shell environment..."
            local brew_path="/home/linuxbrew/.linuxbrew/bin/brew"
            
            # Add to current session
            eval "$($brew_path shellenv)"

            # Add to shell config file
            local shell_name
            shell_name=$(basename "$SHELL")
            
            case "$shell_name" in
                bash)
                    local profile_file="$HOME/.bash_profile"
                    if [ ! -f "$profile_file" ]; then
                        profile_file="$HOME/.profile"
                    fi
                    echo "" >> "$profile_file"
                    echo "eval \"$("$brew_path" shellenv)\"" >> "$profile_file"
                    print_success "Homebrew added to $profile_file"
                    ;;
                zsh)
                    local zshrc_file="$HOME/.zshrc"
                    echo "" >> "$zshrc_file"
                    echo "eval \"$("$brew_path" shellenv)\"" >> "$zshrc_file"
                    print_success "Homebrew added to $zshrc_file"
                    ;;
                fish)
                    local fish_config_file="$HOME/.config/fish/config.fish"
                    mkdir -p "$(dirname "$fish_config_file")"
                    echo "" >> "$fish_config_file"
                    echo "eval ($brew_path shellenv)" >> "$fish_config_file"
                    print_success "Homebrew added to $fish_config_file"
                    ;;
                *)
                    print_warning "Could not determine shell. Please add Homebrew to your PATH manually."
                    print_warning "Add the following to your shell configuration file:"
                    print_warning "  eval \"$("$brew_path" shellenv)\""
                    ;;
            esac
        fi
    else
        print_info "Homebrew is already installed."
    fi
}

print_info "Starting package installation..."

install_homebrew

print_info "Installing packages with Homebrew..."

PACKAGES=(
    # nvim
    "neovim"
    "git"
    "fzf"
    "ripgrep"
    "fd"
    "node"
    "npm"
    "luarocks"

    # tmux
    "tmux"
    "lazygit"

    # alacritty
    "alacritty"
    "font-jetbrains-mono-nerd-font"

    # fish
    "fish"
)

for package in "${PACKAGES[@]}"; do
    install_brew_package "$package"
done

print_success "All packages installed."

# Install TPM (Tmux Plugin Manager) if not already installed
tpm_path="$HOME/.config/tmux/plugins/tpm"
if [ ! -d "$tpm_path" ]; then
    print_info "Installing TPM (Tmux Plugin Manager)..."
    git clone https://github.com/tmux-plugins/tpm "$tpm_path"
    print_success "TPM installed successfully"
else
    print_info "TPM is already installed (skipping)"
fi

print_success "Dotfiles installation completed!"
print_info ""
print_info "Next steps:"
print_info "  - Reload your shell or log out/in for changes to take effect."
print_info "  - Run 'nvim' to automatically install plugins."
print_info "  - Run 'prefix + I' in tmux to install plugins (prefix is Ctrl-a)."