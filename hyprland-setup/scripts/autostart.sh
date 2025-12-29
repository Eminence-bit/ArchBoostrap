#!/bin/bash

# Hyprland autostart script

# Start polkit agent (KDE version as specified)
/usr/lib/polkit-kde-authentication-agent-1 &

# Start network manager applet
nm-applet --indicator &

# Start clipboard manager with cliphist
wl-paste --type text --watch cliphist store &
wl-paste --type image --watch cliphist store &

echo "Autostart completed"