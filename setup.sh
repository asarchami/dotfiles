#!/bin/bash

set -e

source ./scripts/utils.sh
source ./scripts/parse_args.sh
source ./scripts/homebrew.sh
source ./scripts/nvim.sh
source ./scripts/tmux.sh
source ./scripts/alacritty.sh
source ./scripts/hypr.sh
source ./scripts/waybar.sh
source ./scripts/fish.sh

# Default values
INSTALL_NVIM=false
INSTALL_TMUX=false
INSTALL_ALACRITTY=false
INSTALL_HYPR=false
INSTALL_WAYBAR=false
INSTALL_FISH=false
DRY_RUN=false

# Main installation function
main() {
    print_info "Starting dotfiles installation..."
    print_info ""
    
    parse_args "$@"

    install_homebrew

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
    if [ "$INSTALL_WAYBAR" = true ]; then
        install_waybar
    fi
    if [ "$INSTALL_FISH" = true ]; then
        install_fish
    fi
    
    print_success "Dotfiles installation completed!"
    print_info ""
    print_info "Next steps:"

    print_shell_reload_info
}

# Run main function
main "$@"