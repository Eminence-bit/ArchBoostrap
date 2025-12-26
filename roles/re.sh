#!/usr/bin/env bash
set -euo pipefail

echo "[+] Installing reverse engineering tools"
sudo pacman -S --noconfirm \
  gdb \
  radare2 \
  binutils \
  strace \
  ltrace \
  python \
  python-pip \
  checksec

echo "[+] Installing Python exploit development tools"
pip install --user pwntools capstone unicorn

echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.profile

echo "[+] RE stack ready"
echo "[*] Note: For Ghidra and IDA Free, download from official sources"
