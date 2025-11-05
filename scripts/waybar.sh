#!/bin/bash

source ./scripts/utils.sh

install_waybar_dependencies() {
    print_info "Installing waybar dependencies..."
    install_brew_package "waybar"
    print_success "waybar dependencies installation completed"
}

install_waybar() {
    print_info "Installing Waybar configuration..."

    install_waybar_dependencies

    if ! command -v waybar >/dev/null 2>&1; then
        print_error "Waybar is not installed. Please install it first."
        exit 1
    fi

    print_success "Waybar is installed."
}

install_waybar
