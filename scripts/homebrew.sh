#!/bin/bash

source ./scripts/utils.sh

install_homebrew() {
    # Check if Homebrew is installed
    if ! command -v brew >/dev/null 2>&1;
 then
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
}
