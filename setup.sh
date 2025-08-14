#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
INSTALL_ALL=false
INSTALL_NVIM=false
INSTALL_TMUX=false
INSTALL_ALACRITTY=false
DRY_RUN=false

# Parse command line arguments
parse_args() {
    if [ $# -eq 0 ]; then
        INSTALL_ALL=true
        return
    fi
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --all)
                INSTALL_ALL=true
                shift
                ;;
            --nvim)
                INSTALL_NVIM=true
                shift
                ;;
            --tmux)
                INSTALL_TMUX=true
                shift
                ;;
            --alacritty)
                INSTALL_ALACRITTY=true
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                print_info "Dry run mode: will check what would be installed without making changes"
                shift
                ;;
            -h|--help)
                echo "Usage: $0 [OPTIONS]"
                echo "Options:"
                echo "  --all       Install all configurations (default)"
                echo "  --nvim      Install only Neovim configuration"
                echo "  --tmux      Install only tmux configuration"
                echo "  --alacritty Install only Alacritty configuration"
                echo "  --dry-run   Show what would be installed without making changes"
                echo "  -h, --help  Show this help message"
                exit 0
                ;;
            *)
                echo -e "${RED}Unknown option: $1${NC}"
                exit 1
                ;;
        esac
    done
}

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

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt-get >/dev/null 2>&1; then
            OS="debian"
        else
            print_error "Unsupported Linux distribution. Only Debian-based systems are supported."
            exit 1
        fi
    else
        print_error "Unsupported operating system: $OSTYPE"
        exit 1
    fi
    print_info "Detected OS: $OS"
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

# Check if a package is installed (macOS)
check_brew_package() {
    local package="$1"
    if brew list "$package" >/dev/null 2>&1; then
        return 0  # Package is installed
    else
        return 1  # Package is not installed
    fi
}

# Check if a package is installed (Debian)
check_apt_package() {
    local package="$1"
    if dpkg -l | grep -q "^ii  $package "; then
        return 0  # Package is installed
    else
        return 1  # Package is not installed
    fi
}

# Install a single brew package if not already installed
install_brew_package() {
    local package="$1"
    if check_brew_package "$package"; then
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

# Install a single apt package if not already installed
install_apt_package() {
    local package="$1"
    if check_apt_package "$package"; then
        print_info "$package is already installed (skipping)"
    else
        if [ "$DRY_RUN" = true ]; then
            print_warning "Would install $package"
        else
            print_info "Installing $package..."
            sudo apt-get install -y "$package"
            print_success "$package installed successfully"
        fi
    fi
}

# Install dependencies
install_dependencies() {
    print_info "Installing core dependencies..."
    
    case $OS in
        macos)
            # Check if Homebrew is installed
            if ! command -v brew >/dev/null 2>&1; then
                if [ "$DRY_RUN" = true ]; then
                    print_warning "Would install Homebrew"
                else
                    print_info "Installing Homebrew..."
                    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                    print_success "Homebrew installed successfully"
                fi
            else
                print_info "Homebrew is already installed (skipping)"
            fi
            
            # Install core dependencies individually (excluding Python and Go)
            # Note: tree-sitter is not needed as system package (Neovim handles it internally)
            local packages=("neovim" "tmux" "alacritty" "git" "lazygit" "fzf" "ripgrep" "fd" "node" "npm" "luarocks")
            for package in "${packages[@]}"; do
                install_brew_package "$package"
            done
            

            ;;
        debian)
            # Fix locale warnings
            export LC_ALL=C.UTF-8
            export LANG=C.UTF-8
            
            sudo apt-get update
            
            # Install basic packages
            local basic_packages=("curl" "git" "build-essential")
            for package in "${basic_packages[@]}"; do
                install_apt_package "$package"
            done
            
            # Install Neovim (latest version)
            print_info "Checking for Neovim installation..."
            if ! command -v nvim >/dev/null 2>&1; then
                if [ "$DRY_RUN" = true ]; then
                    print_warning "Would install Neovim from AppImage"
                else
                    print_info "Installing Neovim..."
                    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
                    chmod u+x nvim.appimage
                    sudo mv nvim.appimage /usr/local/bin/nvim
                    print_success "Neovim installed successfully"
                fi
            else
                local nvim_path=$(command -v nvim)
                print_info "Neovim is already installed at $nvim_path (skipping binary installation)"
            fi
            
            # Install Alacritty from official PPA (newer than apt version)
            if ! command -v alacritty >/dev/null 2>&1; then
                if [ "$DRY_RUN" = true ]; then
                    print_warning "Would install Alacritty from GitHub releases"
                else
                    print_info "Installing Alacritty..."
                    # Install via cargo if rust is available, otherwise use AppImage
                    if command -v cargo >/dev/null 2>&1; then
                        cargo install alacritty
                    else
                        # Download latest Alacritty AppImage
                        curl -L "https://github.com/alacritty/alacritty/releases/latest/download/Alacritty-v*-ubuntu_18_04_amd64.AppImage" -o alacritty.appimage
                        chmod +x alacritty.appimage
                        sudo mv alacritty.appimage /usr/local/bin/alacritty
                    fi
                    print_success "Alacritty installed successfully"
                fi
            else
                print_info "Alacritty is already installed (skipping)"
            fi
            

            
            # Install other core dependencies (excluding Python and Go)
            # Note: tree-sitter is not needed as system package (Neovim handles it internally)
            local packages=("tmux" "fzf" "ripgrep" "fd-find" "nodejs" "npm" "luarocks")
            for package in "${packages[@]}"; do
                install_apt_package "$package"
            done
            
            # Install lazygit
            if ! command -v lazygit >/dev/null 2>&1; then
                if [ "$DRY_RUN" = true ]; then
                    print_warning "Would install lazygit from GitHub releases"
                else
                    print_info "Installing lazygit..."
                    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
                    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
                    tar xf lazygit.tar.gz lazygit
                    sudo install lazygit /usr/local/bin
                    rm lazygit.tar.gz lazygit
                    print_success "lazygit installed successfully"
                fi
            else
                print_info "lazygit is already installed (skipping)"
            fi
            ;;
    esac
    
    print_success "Core dependencies installation completed"
    
    # Check for optional language dependencies
    check_language_dependencies
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

# Install Neovim configuration
install_nvim() {
    print_info "Installing Neovim configuration..."
    
    local nvim_config_path="$HOME/.config/nvim"
    
    # Check if config already exists and is identical
    if [ -d "$nvim_config_path" ]; then
        if diff -r "./nvim" "$nvim_config_path" >/dev/null 2>&1; then
            print_info "Neovim configuration is already up to date (skipping)"
            return
        else
            print_info "Existing Neovim configuration differs from dotfiles version"
            if [ "$DRY_RUN" = true ]; then
                print_warning "Would backup existing config and install new Neovim configuration"
                return
            fi
            # Create backup if config exists
            create_backup "$nvim_config_path"
        fi
    else
        if [ "$DRY_RUN" = true ]; then
            print_warning "Would install Neovim configuration"
            return
        fi
    fi
    
    # Remove existing config
    rm -rf "$nvim_config_path"
    
    # Copy new config
    mkdir -p "$HOME/.config"
    cp -r "./nvim" "$nvim_config_path"
    
    print_success "Neovim configuration installed"
    print_info "Run 'nvim' to automatically install plugins"
    print_info ""
    print_info "Language-specific plugins will only load when working on relevant projects:"
    print_info "  - Python plugins load when working in Python projects"
    print_info "  - Go plugins load when working in Go projects"
    print_info "  - Core plugins always available"
}

# Install tmux configuration
install_tmux() {
    print_info "Installing tmux configuration..."
    
    local tmux_config_path="$HOME/.config/tmux"
    
    # Check if config already exists and is identical
    if [ -d "$tmux_config_path" ]; then
        if diff -r "./tmux" "$tmux_config_path" >/dev/null 2>&1; then
            print_info "tmux configuration is already up to date (skipping)"
            return
        else
            print_info "Existing tmux configuration differs from dotfiles version"
            if [ "$DRY_RUN" = true ]; then
                print_warning "Would backup existing config and install new tmux configuration"
                return
            fi
            create_backup "$tmux_config_path"
        fi
    else
        if [ "$DRY_RUN" = true ]; then
            print_warning "Would install tmux configuration"
            return
        fi
    fi
    
    # Remove existing config and copy new config
    rm -rf "$tmux_config_path"
    mkdir -p "$HOME/.config"
    cp -r "./tmux" "$tmux_config_path"
    
    # Install TPM (Tmux Plugin Manager) if not already installed
    local tpm_path="$HOME/.config/tmux/plugins/tpm"
    if [ ! -d "$tpm_path" ]; then
        if [ "$DRY_RUN" = true ]; then
            print_warning "Would install TPM (Tmux Plugin Manager)"
        else
            print_info "Installing TPM (Tmux Plugin Manager)..."
            git clone https://github.com/tmux-plugins/tpm "$tpm_path"
            print_success "TPM installed successfully"
        fi
    else
        print_info "TPM is already installed (skipping)"
    fi
    
    print_success "tmux configuration installed"
    print_info "Note: Run 'prefix + I' in tmux to install plugins (prefix is Ctrl-a)"
}

# Install Alacritty configuration
# Install JetBrains Mono Nerd Font for Alacritty
install_jetbrains_font() {
    case "$OS" in
        darwin)
            install_brew_package "font-jetbrains-mono-nerd-font"
            ;;
        debian)
            # Install fontconfig if not present
            if ! command -v fc-list >/dev/null 2>&1; then
                install_apt_package "fontconfig"
            fi
            
            # Install unzip if not present (needed for font installation)
            if ! command -v unzip >/dev/null 2>&1; then
                install_apt_package "unzip"
            fi
            
            # Install font
            if command -v fc-list >/dev/null 2>&1; then
                if ! fc-list | grep -i "JetBrainsMono.*Nerd" >/dev/null 2>&1; then
                    if [ "$DRY_RUN" = true ]; then
                        print_warning "Would install JetBrains Mono Nerd Font"
                    else
                        print_info "Installing JetBrains Mono Nerd Font..."
                        mkdir -p ~/.local/share/fonts
                        cd ~/.local/share/fonts || exit 1
                        curl -fLo "JetBrains Mono Regular Nerd Font Complete.ttf" \
                            "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip" 2>/dev/null && \
                        unzip -o JetBrainsMono.zip "*.ttf" 2>/dev/null && \
                        rm -f JetBrainsMono.zip
                        fc-cache -fv >/dev/null 2>&1
                        cd - > /dev/null || exit 1
                        print_success "JetBrains Mono Nerd Font installed successfully"
                    fi
                else
                    print_info "JetBrains Mono Nerd Font is already installed (skipping)"
                fi
            else
                print_info "Skipping font installation (no GUI environment detected)"
                print_info "To install manually: https://www.jetbrains.com/lp/mono/"
            fi
            ;;
    esac
}

install_alacritty() {
    print_info "Installing Alacritty configuration..."
    
    # Install the font first
    install_jetbrains_font
    
    local alacritty_config_path="$HOME/.config/alacritty"
    
    # Check if config already exists and is identical
    if [ -d "$alacritty_config_path" ]; then
        if diff -r "./alacritty" "$alacritty_config_path" >/dev/null 2>&1; then
            print_info "Alacritty configuration is already up to date (skipping)"
            return
        else
            print_info "Existing Alacritty configuration differs from dotfiles version"
            if [ "$DRY_RUN" = true ]; then
                print_warning "Would backup existing config and install new Alacritty configuration"
                return
            fi
            create_backup "$alacritty_config_path"
        fi
    else
        if [ "$DRY_RUN" = true ]; then
            print_warning "Would install Alacritty configuration"
            return
        fi
    fi
    
    # Remove existing config and copy new config
    rm -rf "$alacritty_config_path"
    mkdir -p "$HOME/.config"
    cp -r "./alacritty" "$alacritty_config_path"
    
    print_success "Alacritty configuration installed"
}

# Main installation function
main() {
    print_info "Starting dotfiles installation..."
    print_info ""
    print_info "Note: This setup assumes Python 3 and Go are already installed on your system."
    print_info "Language-specific features will only be available if the respective languages are installed."
    print_info ""
    
    parse_args "$@"
    detect_os
    install_dependencies
    
    # Determine what to install
    if [ "$INSTALL_ALL" = true ]; then
        install_nvim
        install_tmux
        install_alacritty
    else
        if [ "$INSTALL_NVIM" = true ]; then
            install_nvim
        fi
        if [ "$INSTALL_TMUX" = true ]; then
            install_tmux
        fi
        if [ "$INSTALL_ALACRITTY" = true ]; then
            install_alacritty
        fi
    fi
    
    print_success "Dotfiles installation completed!"
    print_info ""
    print_info "Next steps:"
    print_info "  1. Reload your shell or run 'source ~/.bashrc' / 'source ~/.zshrc'"
    print_info "  2. Run 'nvim' to automatically install plugins"
    print_info "  3. Language-specific plugins will auto-load based on your project type"
    print_info "  4. JetBrains Mono font is auto-installed with Alacritty"
    print_info ""
    print_info "If you install Python 3 or Go later, restart Neovim to enable those features."
}

# Run main function
main "$@" 