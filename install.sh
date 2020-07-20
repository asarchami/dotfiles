#!/usr/bin/env bash

set -e
set -u
set -o pipefail

is_app_installed() {
  type "$1" &>/dev/null
}

if ! is_app_installed tmux; then
  printf "WARNING: \"tmux\" command is not found. \
Install it first\n"
  exit 1
fi

rm -rf dotfiles
git clone  https://github.com/asarchami/dotfiles.git
rm -rf ~/.config/nvim-back && mv ~/.config/nvim ~/.config/nvim-back || true
rm -rf ~/.tmux && mv ~/.tmux ~/.tmux-back || true
rm -rf ~/.tmux.conf && mv ~/.tmux.conf ~/.tmux.conf-back || true
mkdir ~/.config/nvim
cp dotfiles/*.vim ~/.config/nvim
cp dotfiles/coc-settings.json ~/.config/nvim
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
cp dotfiles/tmux.conf ~/.tmux.conf
rm -rf dotfiles
