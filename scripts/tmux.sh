#!/bin/bash

source ./scripts/utils.sh

install_tmux_dependencies() {
    print_info "Installing tmux dependencies..."
    local packages=("tmux" "lazygit")
    for package in "${packages[@]}"; do
        install_brew_package "$package"
    done
    print_success "tmux dependencies installation completed"
}

install_tmux() {
    print_info "Installing tmux configuration..."
    
    install_tmux_dependencies

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

