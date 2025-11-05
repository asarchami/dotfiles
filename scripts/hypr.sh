#!/bin/bash

source ./scripts/utils.sh

install_hypr_dependencies() {
    print_info "Installing hypr dependencies..."
    # Add any hypr dependencies here
    print_success "hypr dependencies installation completed"
}

install_hypr() {
    print_info "Installing Hyprland configuration..."

    install_hypr_dependencies
    
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
    print_info "  - Reload Hyprland (e.g., $mainMod + SHIFT + R) for changes to take effect."
}

