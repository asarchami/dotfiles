#!/usr/bin/env bash

set -e
set -u
set -o pipefail

is_app_installed() {
	type "$1" &>/dev/null
}

install_nvim() {
	nvim_link="https://github.com/neovim/neovim/releases/download/stable/nvim.appimage"
	mkdir -p ~/.local/bin
	curl -Lo ~/.local/bin/nvim.appimage https://github.com/neovim/neovim/releases/download/stable/nvim.appimage &&
		chmod +x nvim.appimage &&
		mv nvim.appimage /usr/local/bin/nvim
}

install_tmux() {
	curl -s https://api.github.com/repos/nelsonenzo/tmux-appimage/releases/latest |
		grep "browser_download_url.*appimage" |
		cut -d : -f 2,3 |
		tr -d \" |
		wget -qi - &&
		chmod +x tmux.appimage &&
		mv tmux.appimage /usr/local/bin/tmux &&
		git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
}

rm -rf dotfiles
git clone https://github.com/asarchami/dotfiles.git

## Tmux
if ! is_app_installed tmux; then
	printf "Error: \"tmux\" is not installed. Installing tmux.\n"
	install_tmux
fi
echo "Installing Tmux plugin manager (tpm)"
rm -rf ~/.tmux/plugins/tpm
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
echo "Copying tmux config"
mkdir -p ~/.config
cp -r dotfiles/tmux ~/.config

## NeoVim
if ! is_app_installed nvim; then
	printf "Warning: \"nvim\" is not installed. Installing nvim.\n"
	install_nvim
fi
# required
echo "Backing up current nvim configs"
mv ~/.config/nvim{,.bak} && mv ~/.local/share/nvim{,.bak} && mv ~/.local/state/nvim{,.bak} && mv ~/.cache/nvim{,.bak}
echo "Installing LazyVim"
git clone https://github.com/LazyVim/starter ~/.config/nvim
echo "Copying nvim config"
mkdir -p ~/.config/nvim
cp dotfiles/nvim ~/.config
echo "Removing dotfiles"
rm -rf dotfiles
