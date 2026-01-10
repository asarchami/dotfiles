#!/bin/bash

# This script installs Oh My Fish if not already installed

if ! command -v fish >/dev/null 2>&1; then
    echo "Fish shell not found. Skipping Oh My Fish installation."
    exit 0
fi

if ! fish -c "type omf > /dev/null 2>&1"; then
    echo "Installing Oh My Fish..."
    curl -fsSL https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish
else
    echo "✅ Oh My Fish is already installed."
fi
