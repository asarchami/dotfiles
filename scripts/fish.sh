#!/bin/bash

source ./scripts/utils.sh

install_fish_dependencies() {
    print_info "Installing fish dependencies..."
    install_brew_package "fish"
    print_success "fish dependencies installation completed"
}

# Install and configure Fish
install_fish() {
    print_info "Checking Fish shell..."

    install_fish_dependencies

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

install_fish
