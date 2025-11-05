#!/bin/bash

source ./scripts/utils.sh

install_nvim_dependencies() {
    print_info "Installing nvim dependencies..."
    local packages=("neovim" "git" "fzf" "ripgrep" "fd" "node" "npm" "luarocks")
    for package in "${packages[@]}"; do
        install_brew_package "$package"
    done
    check_language_dependencies
    print_success "nvim dependencies installation completed"
}

install_nvim() {
    print_info "Installing Neovim configuration..."

    install_nvim_dependencies
    
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

