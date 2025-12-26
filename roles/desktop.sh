#!/usr/bin/env bash
set -euo pipefail

sudo pacman -S --noconfirm \
  xorg-server \
  xorg-xinit \
  xfce4 \
  xfce4-goodies \
  lightdm \
  lightdm-gtk-greeter \
  pulseaudio \
  pavucontrol \
  firefox

sudo systemctl enable lightdm

echo "[+] Desktop installed"
