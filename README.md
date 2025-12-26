# ArchBootstrap

A collection of bash scripts to quickly bootstrap a fresh Arch Linux installation with your preferred tools and configurations.

⚠️ WARNING  
These scripts assume a fresh Arch installation.
Review all scripts before running on any existing system.

## Overview

This project contains modular installation scripts that set up Arch Linux with:
- **Base system packages** - Essential development tools, git, vim, tmux, etc.
- **User environment** - Shell (zsh), prompt (starship), fzf, ripgrep, and workspace directories
- **Desktop** - XFCE4 desktop environment with LightDM and audio
- **Development** - Node.js, Python, Docker
- **Reverse Engineering** - GDB, Radare2, pwntools, and debugging tools

## Prerequisites

- Fresh Arch Linux installation with internet access
- Root or sudo access
- Boot into the live Arch ISO or fresh install

## Quick Start

```bash
# Clone the repository
git clone https://github.com/yourusername/ArchBootstrap.git
cd ArchBootstrap

# Run individual scripts or use the main installer (see below)
bash base.sh           # System basics (required)
bash user.sh           # User tools and shell setup
bash roles/desktop.sh  # Desktop environment
bash roles/dev.sh      # Development tools
bash roles/re.sh       # Reverse engineering tools
```

## Script Details

### base.sh
Updates system and installs essential packages:
- Build tools: `base-devel`, `git`
- Utilities: `curl`, `wget`, `unzip`, `zip`
- Editors: `neovim`
- Terminal: `tmux`
- System: `htop`, `man-db`, `openssh`, `networkmanager`

**Note:** Must be run first.

### user.sh
Sets up user environment and configurations:
- Shell: `zsh` with `starship` prompt
- Tools: `fzf`, `ripgrep`, `fd`
- Git: Default branch set to `main`
- Creates workspace directories: `~/projects`, `~/tools`, `~/.config`

**Note:** Requires logout/login after running for shell changes to take effect.

### roles/desktop.sh
Installs desktop environment:
- Display: `xorg-server`, `xorg-xinit`
- DE: `xfce4`, `xfce4-goodies`
- Login manager: `lightdm`, `lightdm-gtk-greeter`
- Audio: `pulseaudio`, `pavucontrol`
- Browser: `firefox`

### roles/dev.sh
Development tools installation:
- Runtime: `nodejs`, `npm`
- Python: `python`, `python-virtualenv`, `pip`
- Containers: `docker`

**Note:** Requires re-login to use docker without sudo.

### roles/re.sh
Reverse engineering and security tools:
- Debuggers: `gdb`
- Analysis: `radare2`, `binutils`, `strace`, `ltrace`
- Exploit dev: `python`, `pip`, `pwntools`

## Customization

Edit individual scripts in `roles/` to add or remove packages for your use case.

## Notes

- Scripts use `set -euo pipefail` for safety
- `--noconfirm` flags skip prompts (edit if you prefer confirmation)
- Some scripts require specific order (e.g., `base.sh` first)
- Always review scripts before running on production systems

## License

MIT
