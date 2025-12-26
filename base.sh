if [[ $EUID -ne 0 ]]; then
  echo "[-] base.sh must be run as root"
  exit 1
fi

#!/usr/bin/env bash
set -euo pipefail

echo "[+] Updating system"
pacman -Syu --noconfirm

echo "[+] Installing base packages"
pacman -S --noconfirm \
  base-devel \
  linux-headers \
  git \
  curl \
  wget \
  neovim \
  tmux \
  htop \
  unzip \
  zip \
  man-db \
  man-pages \
  openssh \
  networkmanager \
  sudo

echo "[+] Enabling NetworkManager"
systemctl enable NetworkManager
systemctl start NetworkManager

echo "[+] Base setup complete"
