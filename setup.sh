#!/bin/bash

rm -rf ~/.vim* 

curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
	    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

curl -fLo ~/.vim/colors/molokai.vim --create-dirs \
        https://raw.githubusercontent.com/tomasr/molokai/master/colors/molokai.vim

cp -f ~/.myvim/vimrc ~/.vimrc
vim +PlugInstall +qall
rm -rf ~/.myvim
