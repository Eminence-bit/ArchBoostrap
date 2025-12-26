#!/usr/bin/env bash
set -euo pipefail

sudo pacman -S --noconfirm \
  nodejs \
  npm \
  yarn \
  python \
  python-pip \
  python-virtualenv \
  docker

sudo systemctl enable docker
sudo usermod -aG docker "$USER"

echo "[+] Dev stack installed (relogin required)"
