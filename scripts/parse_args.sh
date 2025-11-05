#!/bin/bash

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
        echo "  --waybar    Install Waybar configuration"
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
            --waybar)
                INSTALL_WAYBAR=true
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
