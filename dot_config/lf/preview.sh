#!/bin/bash

# This script is used by lf to preview files.

case "$1" in
    *.tar*) tar tf "$1";;
    *.zip) unzip -l "$1";;
    *.rar) unrar l "$1";;
    *.7z) 7z l "$1";;
    *.pdf) pdftotext "$1" -;;
    *.appimage)   ./"$1" --appimage-extract >/dev/null 2>&1 && tree squashfs-root || true ;;
    *) highlight -O ansi -l "$1" || cat "$1";;
esac