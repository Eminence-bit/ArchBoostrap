#!/usr/bin/env bash
set -euo pipefail

echo "[+] Installing user packages"
sudo pacman -S --noconfirm \
  zsh \
  starship \
  fzf \
  ripgrep \
  fd \
  bat \
  eza \
  lazygit

grep -qxF /bin/zsh /etc/shells || echo /bin/zsh | sudo tee -a /etc/shells

echo "[+] Setting zsh as default shell"
chsh -s /bin/zsh

echo "[+] Basic git config"
git config --global init.defaultBranch main
git config --global pull.rebase false

echo "[+] Creating workspace directories"
mkdir -p ~/projects ~/tools ~/.config

echo "[+] User setup complete (logout required)"
