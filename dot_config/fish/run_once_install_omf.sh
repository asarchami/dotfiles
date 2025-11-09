#!/bin/bash

if ! fish -c "type omf > /dev/null 2>&1"; then
    echo "Installing Oh My Fish..."
    curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish
else
    echo "Oh My Fish is already installed."
fi
