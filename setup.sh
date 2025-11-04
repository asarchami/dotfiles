#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
INSTALL_NVIM=false
INSTALL_TMUX=false
INSTALL_ALACRITTY=false
INSTALL_HYPR=false
INSTALL_FISH=false
DRY_RUN=false

# Parse command line arguments
parse_args() {
    if [ $# -eq 0 ]; then
        echo "Usage: $0 [OPTIONS]"
        echo "Error: No options provided. Please specify what to install."
        echo ""
        echo "Options:"
        echo "  --nvim      Install Neovim configuration"
        echo "  --tmux      Install tmux configuration"
        echo "  --alacritty Install Alacritty configuration"
        echo "  --hypr      Install Hyprland configuration"
        echo "  --fish      Install Fish configuration"
        echo "  --dry-run   Show what would be installed without making changes"
        echo "  -h, --help  Show this help message"
        exit 1
    fi
    
    while [[ $# -gt 0 ]]; do
        case $1 in
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
            --hypr)
                INSTALL_HYPR=true
                shift
                ;;
            --fish)
                INSTALL_FISH=true
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
                echo "  --nvim      Install Neovim configuration"
                echo "  --tmux      Install tmux configuration"
                echo "  --alacritty Install Alacritty configuration"
                echo "  --hypr      Install Hyprland configuration"
                echo "  --fish      Install Fish configuration"
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

# Install dependencies
install_dependencies() {
    print_info "Installing core dependencies..."
    
    # Install core dependencies individually (excluding Python and Go)
    # Note: tree-sitter is not needed as system package (Neovim handles it internally)
    local packages=("git" "fzf" "ripgrep" "fd" "node" "npm" "luarocks")
    
    # Add packages based on what's being installed
    if [ "$INSTALL_NVIM" = true ]; then
        packages+=("neovim")
    fi
    if [ "$INSTALL_TMUX" = true ]; then
        packages+=("tmux" "lazygit")
    fi
    if [ "$INSTALL_ALACRITTY" = true ]; then
        packages+=("alacritty" "tmux")
    fi
    
    for package in "${packages[@]}"; do
        install_brew_package "$package"
    done
    
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
    install_brew_package "font-jetbrains-mono-nerd-font"
}

install_alacritty() {
    print_info "Installing Alacritty configuration..."
    
    # Install the font first
    install_jetbrains_font
    
    local alacritty_config_path="$HOME/.config/alacritty"
    local source_config_file="./alacritty/alacritty.toml"
    local dest_config_file="$alacritty_config_path/alacritty.toml"

    # Find tmux path
    local tmux_path
    tmux_path=$(command -v tmux)
    if [ -z "$tmux_path" ]; then
        print_error "tmux not found, but it should have been installed. Aborting alacritty setup."
        return 1
    fi

    # Create a temporary file with the correct tmux path
    local temp_config
    temp_config=$(mktemp)
    local escaped_tmux_path
    escaped_tmux_path=$(printf '%s\n' "$tmux_path" | sed 's:[&/]:\\\\&:g')
    sed "s|TMUX_PATH_PLACEHOLDER|$escaped_tmux_path|" "$source_config_file" > "$temp_config"

    # Now, compare the generated config with the existing one.
    if [ -f "$dest_config_file" ]; then
        if diff -q "$temp_config" "$dest_config_file" >/dev/null 2>&1; then
            print_info "Alacritty configuration is already up to date (skipping)"
            rm "$temp_config"
            return
        else
            print_info "Existing Alacritty configuration differs from dotfiles version"
            if [ "$DRY_RUN" = true ]; then
                print_warning "Would backup existing config and install new Alacritty configuration"
                rm "$temp_config"
                return
            fi
            create_backup "$alacritty_config_path"
        fi
    else
        if [ "$DRY_RUN" = true ]; then
            print_warning "Would install Alacritty configuration"
            rm "$temp_config"
            return
        fi
    fi
    
    # Install the new configuration
    mkdir -p "$alacritty_config_path"
    mv "$temp_config" "$dest_config_file"
    
    print_success "Alacritty configuration installed"
}

# Install Hyprland configuration
install_hypr() {
    print_info "Installing Hyprland configuration..."
    
    local hypr_config_path="$HOME/.config/hypr"
    
    # Check if config already exists and is identical
    if [ -d "$hypr_config_path" ]; then
        if diff -r "./hypr" "$hypr_config_path" >/dev/null 2>&1; then
            print_info "Hyprland configuration is already up to date (skipping)"
            return
        else
            print_info "Existing Hyprland configuration differs from dotfiles version"
            if [ "$DRY_RUN" = true ]; then
                print_warning "Would backup existing config and install new Hyprland configuration"
                return
            fi
            create_backup "$hypr_config_path"
            # Clear the directory instead of removing it
            find "$hypr_config_path" -mindepth 1 -delete
        fi
    else
        if [ "$DRY_RUN" = true ]; then
            print_warning "Would install Hyprland configuration"
            return
        fi
        mkdir -p "$hypr_config_path"
    fi
    
    # Copy new config
    cp -r ./hypr/* "$hypr_config_path"
    
    print_success "Hyprland configuration installed"
}

# Install and configure Fish
install_fish() {
    print_info "Checking Fish shell..."

    # Check if fish is installed
    if ! command -v fish >/dev/null 2>&1; then
        echo "Fish shell is not installed."
        read -p "Do you want to install Fish now via Homebrew? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_info "Installing Fish..."
            brew install fish
            print_success "Fish installed successfully"
        else
            print_error "Fish shell installation was declined. Cannot proceed with Fish setup."
            exit 1
        fi
    else
        print_info "Fish shell is already installed."
    fi

    # Ask to configure fish
    read -p "Do you want to run 'fish_config' to configure Fish? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Running 'fish_config'. Please follow the on-screen instructions."
        fish_config
    else
        print_info "Skipping Fish configuration."
    fi
    
    print_success "Fish setup completed."
}

# Main installation function
main() {
    print_info "Starting dotfiles installation..."
    print_info ""
    print_info "Note: Python 3 and Go are optional dependencies."
    print_info "Language-specific features will only be available if the respective languages are installed."
    print_info "If Go is not installed, Go-related tools will be automatically skipped."
    print_info ""
    
    parse_args "$@"

    # Check if Homebrew is installed
    if ! command -v brew >/dev/null 2>&1; then
        echo "Homebrew is not installed. It is required to install dependencies."
        read -p "Do you want to install Homebrew now? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
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
                        echo "eval \"\$($brew_path shellenv)\"" >> "$profile_file"
                        print_success "Homebrew added to $profile_file"
                        ;;
                    zsh)
                        local zshrc_file="$HOME/.zshrc"
                        echo "" >> "$zshrc_file"
                        echo "eval \"\$($brew_path shellenv)\"" >> "$zshrc_file"
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
                        print_warning "  eval \"\$($brew_path shellenv)\""
                        ;;
                esac
            fi
        else
            print_error "Homebrew is required for this script. Exiting."
            exit 1
        fi
    else
        print_info "Homebrew is already installed."
    fi

    install_dependencies
    
    # Determine what to install
    if [ "$INSTALL_NVIM" = true ]; then
        install_nvim
    fi
    if [ "$INSTALL_TMUX" = true ]; then
        install_tmux
    fi
    if [ "$INSTALL_ALACRITTY" = true ]; then
        install_alacritty
    fi
    if [ "$INSTALL_HYPR" = true ]; then
        install_hypr
    fi
    if [ "$INSTALL_FISH" = true ]; then
        install_fish
    fi
    
    print_success "Dotfiles installation completed!"
    print_info ""
    print_info "Next steps:"

    local has_shell_changes=false
    if [ "$INSTALL_FISH" = true ] || [ "$INSTALL_TMUX" = true ] || [ "$INSTALL_ALACRITTY" = true ] || [ "$INSTALL_HYPR" = true ]; then
        has_shell_changes=true
    fi

    if [ "$has_shell_changes" = true ]; then
        print_info "  - Reload your shell or log out/in for changes to take effect."
    fi

    if [ "$INSTALL_NVIM" = true ]; then
        print_info "  - Run 'nvim' to automatically install plugins."
        print_info "  - Language-specific plugins will auto-load based on your project type."
        print_info "  - If you install Python 3 or Go later, restart Neovim to enable those features."
        print_info "  - Go tools are completely optional and will be skipped if Go is not installed."
    fi

    if [ "$INSTALL_ALACRITTY" = true ]; then
        print_info "  - JetBrains Mono font is auto-installed with Alacritty."
    fi

    if [ "$INSTALL_HYPR" = true ]; then
        print_info "  - Reload Hyprland (e.g., $mainMod + SHIFT + R) for changes to take effect."
    fi
}

# Run main function
main "$@" 