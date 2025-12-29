#!/bin/bash

# Screenshot script using grim and slurp

DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"

case "$1" in
    "area")
        grim -g "$(slurp)" "$DIR/screenshot-$(date +%Y%m%d-%H%M%S).png"
        notify-send "Screenshot" "Area screenshot saved"
        ;;
    "window")
        grim -g "$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')" "$DIR/screenshot-$(date +%Y%m%d-%H%M%S).png"
        notify-send "Screenshot" "Window screenshot saved"
        ;;
    *)
        grim "$DIR/screenshot-$(date +%Y%m%d-%H%M%S).png"
        notify-send "Screenshot" "Full screen screenshot saved"
        ;;
esac