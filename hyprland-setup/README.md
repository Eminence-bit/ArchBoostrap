# Hyprland Setup

A comprehensive, beginner-friendly Hyprland desktop environment setup for Arch Linux with beautiful Catppuccin Mocha theming.

## 🌟 Features

- **Complete Setup Wizard** - Interactive TUI guide for beginners
- **Beautiful Catppuccin Mocha Theme** - Consistent theming across all components
- **Modular Configuration** - Clean, organized config files
- **Multiple Installation Options** - From complete automation to selective installation
- **Professional UI** - Modern rounded elements and smooth animations
- **Optimized for Wayland** - Full Wayland compatibility with fallbacks

## 📦 What's Included

### Core Components
- **Window Manager**: Hyprland - Modern Wayland compositor
- **Status Bar**: Waybar - Highly customizable with Catppuccin theme
- **App Launcher**: Wofi - Fast application launcher with custom styling
- **Terminal**: Kitty - GPU-accelerated with Catppuccin Mocha colors
- **Lock Screen**: Swaylock-effects - Beautiful lock screen with blur effects
- **Notifications**: Mako - Lightweight notification daemon
- **File Manager**: Thunar (GUI) + yazi (Terminal) - Dual file management setup

### System Integration
- **Audio**: PipeWire - Modern, low-latency audio system
- **Portals**: xdg-desktop-portal-hyprland - Proper Wayland integration
- **Authentication**: polkit-kde-agent - Secure privilege escalation
- **Networking**: NetworkManager - Reliable network management
- **Fonts**: JetBrains Mono, Noto Fonts - Beautiful, readable fonts

### Development Tools
- **Editor**: Neovim - Modern terminal editor with sensible defaults
- **Compiler**: GCC, GDB - Complete C/C++ development environment
- **Assembly**: NASM - Assembly language support
- **Version Control**: Git - Essential development tool
- **Browser**: Google Chrome - Best Wayland support and performance

## 🚀 Quick Start

### For Complete Beginners (Fresh Arch Linux)

If you just installed Arch Linux and are in TTY with no desktop environment:

```bash
# Install git if not already installed
sudo pacman -S git

# Clone the repository
git clone https://github.com/yourusername/hyprland-setup.git
cd hyprland-setup

# Run the complete setup wizard
./setup.sh
```

The setup wizard will guide you through:
- Display manager selection (SDDM, GDM, LightDM, ly)
- Audio system configuration (PipeWire, PulseAudio, ALSA)
- Browser selection (Chrome, Firefox, Brave, etc.)
- Development tools (Full stack, Basic, System, Web, Python)
- File manager setup (Dual, GUI-only, Terminal-only)
- Additional applications (Media, Graphics, Office, Gaming)
- Theme selection (Catppuccin variants, Nord, Dracula)

### For Existing Hyprland Users

If you already have Hyprland and want to apply this configuration:

```bash
git clone https://github.com/yourusername/hyprland-setup.git
cd hyprland-setup

# Run the enhanced installer
./install.sh
```

Choose from:
1. **Full installation** - Complete automated setup
2. **Install packages only** - Just install required packages
3. **Copy configuration files only** - Apply configs without packages
4. **System setup only** - Configure system files and services
5. **Custom installation** - Choose specific components

## 📁 Project Structure

```
hyprland-setup/
├── README.md                 # This file
├── setup.sh                  # Complete setup wizard for beginners
├── install.sh                # Enhanced installer with options
├── packages/                 # Package lists
│   ├── base.txt             # Essential Hyprland packages
│   ├── dev.txt              # Development tools
│   └── optional.txt         # Optional applications
├── hypr/                    # Hyprland configuration
│   ├── hyprland.conf        # Main config file
│   ├── env.conf             # Environment variables
│   ├── input.conf           # Input device settings
│   ├── binds.conf           # Key bindings
│   ├── layout.conf          # Window layout settings
│   ├── rules.conf           # Window rules
│   ├── animations.conf      # Animation settings
│   └── decoration.conf      # Visual effects
├── waybar/                  # Status bar configuration
│   ├── config               # Waybar configuration
│   └── style.css            # Catppuccin Mocha styling
├── wofi/                    # Application launcher
│   ├── config               # Wofi settings
│   └── style.css            # Catppuccin Mocha theme
├── kitty/                   # Terminal emulator
│   ├── kitty.conf           # Main configuration
│   └── mocha.conf           # Catppuccin Mocha colors
├── swaylock/                # Lock screen
│   └── config               # Swaylock-effects config
├── mako/                    # Notifications
│   └── config               # Notification styling
├── nvim/                    # Neovim editor
│   └── init.lua             # Basic Neovim configuration
├── scripts/                 # Utility scripts
│   ├── autostart.sh         # Autostart applications
│   ├── clipboard.sh         # Clipboard management
│   ├── screenshot.sh        # Screenshot utilities
│   └── yazi.sh              # Terminal file manager launcher
└── system/                  # System-level configurations
    ├── environment          # Environment variables
    └── xdg-portal.conf      # XDG portal configuration
```

## ⌨️ Key Bindings

### Applications
- `Super + Q` - Open terminal (Kitty)
- `Super + Space` - Application launcher (Wofi)
- `Super + E` - File manager (Thunar)
- `Super + Shift + E` - Terminal file manager (yazi)
- `Super + B` - Web browser (Google Chrome)
- `Super + L` - Lock screen (Swaylock)

### Window Management
- `Super + Shift + X` - Close active window
- `Super + V` - Toggle floating mode
- `Super + P` - Toggle pseudotile
- `Super + J` - Toggle split direction
- `Super + M` - Exit Hyprland

### Navigation
- `Super + Arrow Keys` - Move focus between windows
- `Super + 1-0` - Switch to workspace 1-10
- `Super + Shift + 1-0` - Move window to workspace 1-10
- `Super + Mouse Scroll` - Switch workspaces

### Screenshots
- `Super + S` - Interactive screenshot with editing (grim + slurp + swappy)
- `Print` - Full screen screenshot
- `Shift + Print` - Area screenshot

### Media Controls
- `XF86AudioRaiseVolume` - Increase volume
- `XF86AudioLowerVolume` - Decrease volume
- `XF86AudioMute` - Toggle mute
- `XF86MonBrightnessUp/Down` - Adjust brightness
- `XF86AudioPlay/Pause/Next/Prev` - Media controls

## 🎨 Theming

The configuration uses the **Catppuccin Mocha** color palette throughout:

- **Background**: `#1e1e2e` - Rich dark background
- **Foreground**: `#cdd6f4` - Soft white text
- **Accent**: `#89b4fa` - Beautiful blue highlights
- **Success**: `#a6e3a1` - Green for positive actions
- **Warning**: `#fab387` - Orange for warnings
- **Error**: `#f38ba8` - Red for errors

All components (Hyprland, Waybar, Wofi, Kitty, Swaylock, Mako) use consistent theming for a cohesive desktop experience.

## 🔧 Customization

### Modifying Colors
To change the theme, update the color values in:
- `waybar/style.css` - Status bar colors
- `wofi/style.css` - Application launcher colors
- `kitty/mocha.conf` - Terminal colors
- `swaylock/config` - Lock screen colors
- `mako/config` - Notification colors

### Adding Applications
1. Add package names to appropriate files in `packages/`
2. Update `hypr/rules.conf` for window rules
3. Add key bindings in `hypr/binds.conf`
4. Update autostart in `scripts/autostart.sh`

### Modifying Layouts
Edit `hypr/layout.conf` to adjust:
- Gap sizes between windows
- Border thickness and colors
- Layout algorithms (dwindle vs master)

## 🛠️ Troubleshooting

### Common Issues

**Hyprland won't start:**
- Ensure you're using a compatible GPU driver
- Check `/var/log/Xorg.0.log` for errors
- Try starting from TTY: `Hyprland`

**Audio not working:**
- Restart audio services: `systemctl --user restart pipewire pipewire-pulse`
- Check audio devices: `pactl list sinks`

**Applications not launching:**
- Verify XDG portals: `systemctl --user status xdg-desktop-portal-hyprland`
- Check environment variables in `system/environment`

**Display manager issues:**
- Check service status: `systemctl status sddm` (or your chosen DM)
- Review logs: `journalctl -u sddm`

### Getting Help

1. Check the [Hyprland Wiki](https://wiki.hyprland.org/)
2. Review configuration files for syntax errors
3. Test with minimal configuration
4. Check system logs: `journalctl -xe`

## 📋 Requirements

### System Requirements
- **OS**: Arch Linux (or Arch-based distribution)
- **GPU**: Any GPU with modern drivers (NVIDIA users need `nvidia-dkms`)
- **RAM**: 4GB minimum, 8GB recommended
- **Storage**: 10GB free space for full installation

### Prerequisites
- Fresh Arch Linux installation with base system
- Internet connection
- User account with sudo privileges
- Basic familiarity with terminal (for troubleshooting)

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make your changes
4. Test thoroughly
5. Submit a pull request

### Areas for Contribution
- Additional theme variants
- More application integrations
- Improved error handling
- Documentation improvements
- Translation support

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Hyprland](https://hyprland.org/) - Amazing Wayland compositor
- [Catppuccin](https://catppuccin.com/) - Beautiful color palette
- [Waybar](https://github.com/Alexays/Waybar) - Excellent status bar
- [Arch Linux](https://archlinux.org/) - The best Linux distribution
- The entire Linux and open-source community

## 📸 Screenshots

*Screenshots will be added showing the beautiful Catppuccin Mocha themed desktop*

---

**⭐ If this setup helped you, please consider starring the repository!**

**🐛 Found a bug or have a suggestion? Please open an issue!**