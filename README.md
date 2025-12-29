# ArchBootstrap

A comprehensive collection of bash scripts and configurations to quickly bootstrap a fresh Arch Linux installation with your preferred tools, desktop environments, and development setups.

## 🎯 What's Included

This repository provides two main installation paths:

### 🖥️ **Hyprland Desktop Setup** (New!)
**Location**: `hyprland-setup/`

A complete, beginner-friendly Hyprland Wayland desktop environment with:
- **Beautiful Catppuccin Mocha Theme** - Consistent theming across all components
- **Interactive Setup Wizard** - Guided installation for complete beginners
- **Modern Wayland Stack** - Hyprland, Waybar, Wofi, Kitty, Swaylock
- **Development Ready** - Neovim, Git, GCC, and essential dev tools
- **Professional UI** - Rounded corners, smooth animations, blur effects

[**→ Go to Hyprland Setup**](hyprland-setup/)

### 🖥️ **Traditional Desktop Setup** (XFCE4)
**Location**: Root directory scripts

Modular bash scripts for traditional desktop environments:
- **Base System** - Essential packages and tools
- **XFCE4 Desktop** - Complete desktop environment with LightDM
- **Development Tools** - Node.js, Python, Docker
- **Reverse Engineering** - GDB, Radare2, pwntools

## ⚠️ Important Warning

**These scripts assume a fresh Arch Linux installation.**  
Review all scripts before running on any existing system to avoid conflicts.

## 🚀 Quick Start

### For Hyprland Desktop (Recommended for New Users)

```bash
# Clone the repository
git clone https://github.com/yourusername/ArchBootstrap.git
cd ArchBootstrap/hyprland-setup

# Run the complete setup wizard (for complete beginners)
./setup.sh

# OR run the flexible installer (for existing Hyprland users)
./install.sh
```

### For Traditional XFCE4 Desktop

```bash
# Clone the repository
git clone https://github.com/yourusername/ArchBootstrap.git
cd ArchBootstrap

# Run scripts in order
bash base.sh           # System basics (required first)
bash user.sh           # User tools and shell setup
bash roles/desktop.sh  # XFCE4 desktop environment
bash roles/dev.sh      # Development tools (optional)
bash roles/re.sh       # Reverse engineering tools (optional)
```

## 📁 Repository Structure

```
ArchBootstrap/
├── README.md                    # This file
├── base.sh                      # Essential system packages
├── user.sh                      # User environment setup
├── utils.sh                     # Shared utility functions
├── roles/                       # Specialized installation scripts
│   ├── desktop.sh              # XFCE4 desktop environment
│   ├── dev.sh                  # Development tools
│   └── re.sh                   # Reverse engineering tools
└── hyprland-setup/             # Complete Hyprland desktop setup
    ├── README.md               # Detailed Hyprland documentation
    ├── setup.sh                # Interactive setup wizard
    ├── install.sh              # Flexible installer
    ├── packages/               # Package lists
    ├── hypr/                   # Hyprland configuration
    ├── waybar/                 # Status bar config
    ├── wofi/                   # App launcher config
    ├── kitty/                  # Terminal config
    └── ...                     # Complete desktop configs
```

## 🛠️ Traditional Scripts (XFCE4 Path)

### base.sh - Essential Foundation
**Must be run first!**

Updates system and installs essential packages:
- **Build tools**: `base-devel`, `git`, `cmake`
- **Utilities**: `curl`, `wget`, `unzip`, `zip`, `tree`
- **Editors**: `neovim`, `vim`
- **Terminal**: `tmux`, `screen`
- **System**: `htop`, `btop`, `man-db`, `openssh`, `networkmanager`
- **Development**: `python`, `nodejs`, `npm`

### user.sh - User Environment
Sets up user environment and shell:
- **Shell**: `zsh` with `oh-my-zsh`
- **Prompt**: `starship` - beautiful, fast prompt
- **Tools**: `fzf`, `ripgrep`, `fd`, `bat`, `exa`
- **Git**: Configuration with sensible defaults
- **Directories**: Creates `~/projects`, `~/tools`, `~/.config`

**Note**: Requires logout/login for shell changes to take effect.

### roles/desktop.sh - XFCE4 Desktop
Complete desktop environment:
- **Display**: `xorg-server`, `xorg-xinit`, `xorg-apps`
- **Desktop**: `xfce4`, `xfce4-goodies`
- **Login**: `lightdm`, `lightdm-gtk-greeter`
- **Audio**: `pulseaudio`, `pavucontrol`, `alsa-utils`
- **Applications**: `firefox`, `thunar`, `mousepad`
- **Themes**: Arc theme and Papirus icons

### roles/dev.sh - Development Environment
Development tools and runtimes:
- **Node.js**: Latest LTS with npm and yarn
- **Python**: Python 3 with pip, virtualenv, and common packages
- **Containers**: Docker with docker-compose
- **Databases**: PostgreSQL, Redis (optional)
- **Tools**: Postman, VS Code (optional)

**Note**: Requires re-login to use docker without sudo.

### roles/re.sh - Reverse Engineering
Security and reverse engineering tools:
- **Debuggers**: `gdb`, `gdb-multiarch`
- **Analysis**: `radare2`, `ghidra`, `binwalk`
- **Network**: `wireshark`, `nmap`, `netcat`
- **Exploit**: `metasploit`, `burpsuite`
- **Python**: `pwntools`, `ropper`, `capstone`

## 🎨 Choosing Your Desktop

### Hyprland (Modern Wayland) - Recommended
**Best for**: New users, modern hardware, beautiful aesthetics

✅ **Pros**:
- Stunning visual effects and animations
- Excellent performance on modern hardware
- Future-proof Wayland technology
- Complete beginner-friendly setup
- Consistent theming throughout

❌ **Cons**:
- Requires modern GPU drivers
- Some older applications may have compatibility issues
- Learning curve for tiling window management

### XFCE4 (Traditional X11)
**Best for**: Older hardware, maximum compatibility, familiar interface

✅ **Pros**:
- Excellent compatibility with all applications
- Lower resource usage
- Familiar desktop paradigm
- Rock-solid stability

❌ **Cons**:
- Less modern visual effects
- X11 is legacy technology
- Manual theming required

## 🔧 Customization

### For Hyprland Setup
See the [detailed Hyprland documentation](hyprland-setup/README.md) for:
- Key binding customization
- Theme modifications
- Adding applications
- Window rules configuration

### For Traditional Scripts
- Edit `roles/*.sh` files to add/remove packages
- Modify `user.sh` for different shell configurations
- Customize `base.sh` for different essential packages

## 📋 Prerequisites

- **Fresh Arch Linux installation** with base system
- **Internet connection** for package downloads
- **Root or sudo access** for system modifications
- **Basic terminal knowledge** (helpful for troubleshooting)

### System Requirements
- **RAM**: 2GB minimum (4GB+ recommended for Hyprland)
- **Storage**: 10GB free space minimum
- **GPU**: Any modern GPU (NVIDIA users need proper drivers for Hyprland)

## 🐛 Troubleshooting

### Common Issues

**Package conflicts:**
```bash
# Update system first
sudo pacman -Syu

# Clear package cache if needed
sudo pacman -Scc
```

**Permission issues:**
```bash
# Ensure user is in wheel group
sudo usermod -aG wheel $USER

# Re-login after group changes
```

**Network issues:**
```bash
# Enable NetworkManager
sudo systemctl enable --now NetworkManager
```

### Getting Help

1. Check script output for specific error messages
2. Review Arch Linux wiki for package-specific issues
3. Ensure system is up to date before running scripts
4. For Hyprland issues, see the [Hyprland documentation](hyprland-setup/README.md)

## 🤝 Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Test your changes on a fresh Arch installation
4. Submit a pull request with clear description

### Areas for Contribution
- Additional desktop environment scripts
- More development environment setups
- Improved error handling
- Documentation improvements
- Package list optimizations

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Arch Linux](https://archlinux.org/) - The best Linux distribution
- [Hyprland](https://hyprland.org/) - Amazing Wayland compositor
- [Catppuccin](https://catppuccin.com/) - Beautiful color schemes
- The entire Arch Linux and open-source community

---

**🌟 Choose Your Path:**
- **New to Linux?** → [Hyprland Setup](hyprland-setup/) (Recommended)
- **Want XFCE4?** → Traditional scripts (this directory)
- **Advanced user?** → Mix and match as needed

**⭐ If this helped you, please star the repository!**
