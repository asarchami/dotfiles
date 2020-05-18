#/usr/bin/bash

git clone --branch add_tmux https://github.com/asarchami/dotfiles.git
rm -rf ~/.config/nvim
mkdir ~/.config/nvim
cp dotfiles/*.vim ~/.config/nvim
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
cp tmux.conf ~/.tmux.conf
rm -rf dotfiles
