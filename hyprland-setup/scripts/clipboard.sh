#!/bin/bash

# Clipboard manager script using cliphist

case "$1" in
    "copy")
        cliphist list | wofi --dmenu | cliphist decode | wl-copy
        ;;
    "clear")
        cliphist wipe
        notify-send "Clipboard" "History cleared"
        ;;
    *)
        echo "Usage: $0 {copy|clear}"
        exit 1
        ;;
esac