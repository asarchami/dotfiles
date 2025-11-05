#!/bin/bash

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

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
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
        if [ "$DRY_RUN" = true ]; then
            print_warning "Would install $package"
        else
            print_info "Installing $package..."
            brew install "$package"
            print_success "$package installed successfully"
        fi
    fi
}

# Create backup
create_backup() {
    local config_path="$1"
    local backup_dir="$HOME/.config/dotfiles-backup/$(date +%Y%m%d_%H%M%S)"
    
    if [ -d "$config_path" ] || [ -f "$config_path" ]; then
        print_info "Creating backup of $config_path"
        mkdir -p "$backup_dir"
        cp -r "$config_path" "$backup_dir/"
        print_success "Backup created at $backup_dir"
    fi
}

print_shell_reload_info() {
    local has_shell_changes=false
    if [ "$INSTALL_FISH" = true ] || [ "$INSTALL_TMUX" = true ] || [ "$INSTALL_ALACRITTY" = true ] || [ "$INSTALL_HYPR" = true ]; then
        has_shell_changes=true
    fi

    if [ "$has_shell_changes" = true ]; then
        print_info "  - Reload your shell or log out/in for changes to take effect."
    fi
}

# Check for optional language dependencies
check_language_dependencies() {
    print_info "Checking for optional language dependencies..."
    
    # Check Python
    if command -v python3 >/dev/null 2>&1; then
        PYTHON_VERSION=$(python3 --version 2>&1 | cut -d' ' -f2)
        print_success "Python 3 found: $PYTHON_VERSION"
    else
        print_warning "Python 3 not found. Python development features will be disabled."
        print_warning "To enable Python support, install Python 3 and restart Neovim."
    fi
    
    # Check Go
    if command -v go >/dev/null 2>&1; then
        GO_VERSION=$(go version | cut -d' ' -f3)
        print_success "Go found: $GO_VERSION"
    else
        print_warning "Go not found. Go development features will be disabled."
        print_warning "To enable Go support, install Go and restart Neovim."
    fi
    
    # Check pip for Python package management
    if command -v pip3 >/dev/null 2>&1; then
        print_success "pip3 found for Python package management"
    elif command -v python3 >/dev/null 2>&1; then
        print_warning "pip3 not found. Some Python tools may not install correctly."
        print_warning "Consider installing pip3 for better Python development experience."
    fi
}
