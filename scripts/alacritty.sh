#!/bin/bash

source ./scripts/utils.sh

install_alacritty_dependencies() {
    print_info "Installing alacritty dependencies..."
    local packages=("alacritty" "tmux")
    for package in "${packages[@]}"; do
        install_brew_package "$package"
    done
    print_success "alacritty dependencies installation completed"
}

# Install JetBrains Mono Nerd Font for Alacritty
install_jetbrains_font() {
    install_brew_package "font-jetbrains-mono-nerd-font"
}

install_alacritty() {
    print_info "Installing Alacritty configuration..."
    
    install_alacritty_dependencies
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
    escaped_tmux_path=$(printf '%s\n' "$tmux_path" | sed 's:[&/]:\\&:g')
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
    print_info "  - JetBrains Mono font is auto-installed with Alacritty."
}

