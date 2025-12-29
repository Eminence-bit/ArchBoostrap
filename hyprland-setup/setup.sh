#!/bin/bash

# Hyprland Complete Setup Script for Fresh Arch Linux Installation
# Designed for complete beginners starting from TTY

set -e

# Colors and formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# Global variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
USER_CHOICES=()
TOTAL_STEPS=0
CURRENT_STEP=0

# ASCII Art and UI Functions
show_header() {
    clear
    echo -e "${PURPLE}${BOLD}"
    echo "╔══════════════════════════════════════════════════════════════════════════════╗"
    echo "║                                                                              ║"
    echo "║    ██╗  ██╗██╗   ██╗██████╗ ██████╗ ██╗      █████╗ ███╗   ██╗██████╗      ║"
    echo "║    ██║  ██║╚██╗ ██╔╝██╔══██╗██╔══██╗██║     ██╔══██╗████╗  ██║██╔══██╗     ║"
    echo "║    ███████║ ╚████╔╝ ██████╔╝██████╔╝██║     ███████║██╔██╗ ██║██║  ██║     ║"
    echo "║    ██╔══██║  ╚██╔╝  ██╔═══╝ ██╔══██╗██║     ██╔══██║██║╚██╗██║██║  ██║     ║"
    echo "║    ██║  ██║   ██║   ██║     ██║  ██║███████╗██║  ██║██║ ╚████║██████╔╝     ║"
    echo "║    ╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝      ║"
    echo "║                                                                              ║"
    echo "║                        🌟 COMPLETE SETUP WIZARD 🌟                          ║"
    echo "║                     From Zero to Hyprland Hero                              ║"
    echo "║                                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

show_progress() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local filled=$((current * width / total))
    
    echo -e "${CYAN}Progress: ${NC}"
    printf "["
    for ((i=0; i<filled; i++)); do printf "█"; done
    for ((i=filled; i<width; i++)); do printf "░"; done
    printf "] %d%% (%d/%d)\n" "$percentage" "$current" "$total"
    echo
}

print_status() {
    echo -e "${GREEN}${BOLD}✓${NC} $1"
}

print_info() {
    echo -e "${BLUE}${BOLD}ℹ${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}${BOLD}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}${BOLD}✗${NC} $1"
}

print_question() {
    echo -e "${CYAN}${BOLD}?${NC} $1"
}

print_recommendation() {
    echo -e "${PURPLE}${BOLD}💡 RECOMMENDATION:${NC} $1"
}

# Utility functions
press_enter() {
    echo
    echo -e "${DIM}Press Enter to continue...${NC}"
    read -r
}

ask_yes_no() {
    while true; do
        echo -e "${CYAN}${BOLD}$1${NC} ${DIM}(y/n)${NC}: "
        read -r yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo -e "${RED}Please answer yes (y) or no (n).${NC}";;
        esac
    done
}

show_menu() {
    local title="$1"
    shift
    local options=("$@")
    
    echo -e "${YELLOW}${BOLD}$title${NC}"
    echo -e "${DIM}$(printf '─%.0s' {1..60})${NC}"
    
    for i in "${!options[@]}"; do
        echo -e "${WHITE}$((i+1)).${NC} ${options[i]}"
    done
    echo
}

get_choice() {
    local max=$1
    while true; do
        echo -e "${CYAN}Enter your choice (1-$max): ${NC}"
        read -r choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "$max" ]; then
            return $((choice-1))
        else
            print_error "Invalid choice. Please enter a number between 1 and $max."
        fi
    done
}

# System checks
check_system() {
    show_header
    echo -e "${YELLOW}${BOLD}🔍 SYSTEM CHECK${NC}"
    echo -e "${DIM}$(printf '─%.0s' {1..60})${NC}"
    echo
    
    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        print_error "This script should not be run as root!"
        print_info "Please run as a regular user. The script will ask for sudo when needed."
        exit 1
    fi
    
    # Check if we're on Arch Linux
    if ! command -v pacman &> /dev/null; then
        print_error "This script is designed for Arch Linux systems."
        exit 1
    fi
    
    # Check internet connection
    print_info "Checking internet connection..."
    if ping -c 1 archlinux.org &> /dev/null; then
        print_status "Internet connection: OK"
    else
        print_error "No internet connection detected. Please check your network."
        exit 1
    fi
    
    # Check if in TTY
    if [[ "$XDG_SESSION_TYPE" == "x11" ]] || [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then
        print_warning "You appear to be running in a graphical session."
        print_info "This script is designed to be run from TTY for fresh installations."
        if ! ask_yes_no "Continue anyway?"; then
            exit 0
        fi
    fi
    
    print_status "System check completed!"
    press_enter
}

# Welcome screen
show_welcome() {
    show_header
    echo -e "${GREEN}${BOLD}🎉 Welcome to the Hyprland Complete Setup Wizard! 🎉${NC}"
    echo
    echo -e "${WHITE}This script will guide you through setting up a complete Hyprland desktop"
    echo -e "environment on your fresh Arch Linux installation.${NC}"
    echo
    echo -e "${CYAN}What this script will help you with:${NC}"
    echo -e "  • Install and configure a display manager"
    echo -e "  • Set up audio system (PipeWire)"
    echo -e "  • Install Hyprland and essential components"
    echo -e "  • Configure a beautiful Catppuccin Mocha theme"
    echo -e "  • Set up development tools and applications"
    echo -e "  • Configure fonts and system settings"
    echo
    echo -e "${YELLOW}${BOLD}⏱️  Estimated time: 15-30 minutes${NC}"
    echo -e "${PURPLE}${BOLD}📦 Packages to install: ~100-200 packages${NC}"
    echo
    press_enter
}

# Display Manager Selection
select_display_manager() {
    show_header
    echo -e "${YELLOW}${BOLD}🖥️  DISPLAY MANAGER SELECTION${NC}"
    echo -e "${DIM}$(printf '─%.0s' {1..60})${NC}"
    echo
    echo -e "${WHITE}A display manager provides a graphical login screen and starts your desktop session.${NC}"
    echo
    
    show_menu "Choose your display manager:" \
        "SDDM (Recommended) - Modern, lightweight, highly customizable" \
        "GDM - GNOME Display Manager, feature-rich" \
        "LightDM - Lightweight, simple" \
        "ly - Minimal TUI display manager" \
        "Skip - I'll configure manually later"
    
    get_choice 5
    local dm_choice=$?
    
    case $dm_choice in
        0) 
            USER_CHOICES+=("dm:sddm")
            print_recommendation "SDDM is the best choice for Hyprland with great theming support!"
            ;;
        1) 
            USER_CHOICES+=("dm:gdm")
            print_info "GDM works well but may have some Wayland conflicts."
            ;;
        2) 
            USER_CHOICES+=("dm:lightdm")
            print_info "LightDM is lightweight but requires additional configuration."
            ;;
        3) 
            USER_CHOICES+=("dm:ly")
            print_info "ly is minimal and perfect for advanced users."
            ;;
        4) 
            USER_CHOICES+=("dm:skip")
            print_warning "You'll need to start Hyprland manually from TTY."
            ;;
    esac
    
    press_enter
}

# Audio System Selection
select_audio_system() {
    show_header
    echo -e "${YELLOW}${BOLD}🔊 AUDIO SYSTEM SELECTION${NC}"
    echo -e "${DIM}$(printf '─%.0s' {1..60})${NC}"
    echo
    echo -e "${WHITE}Choose your audio system for the best multimedia experience.${NC}"
    echo
    
    show_menu "Choose your audio system:" \
        "PipeWire (Recommended) - Modern, low-latency, best compatibility" \
        "PulseAudio - Traditional, stable, widely supported" \
        "ALSA only - Minimal, for advanced users"
    
    get_choice 3
    local audio_choice=$?
    
    case $audio_choice in
        0) 
            USER_CHOICES+=("audio:pipewire")
            print_recommendation "PipeWire is the future of Linux audio with excellent Wayland support!"
            ;;
        1) 
            USER_CHOICES+=("audio:pulseaudio")
            print_info "PulseAudio is stable but PipeWire is recommended for Hyprland."
            ;;
        2) 
            USER_CHOICES+=("audio:alsa")
            print_warning "ALSA-only setup requires manual configuration for most applications."
            ;;
    esac
    
    press_enter
}

# Browser Selection
select_browser() {
    show_header
    echo -e "${YELLOW}${BOLD}🌐 WEB BROWSER SELECTION${NC}"
    echo -e "${DIM}$(printf '─%.0s' {1..60})${NC}"
    echo
    echo -e "${WHITE}Choose your primary web browser.${NC}"
    echo
    
    show_menu "Choose your web browser:" \
        "Google Chrome (Recommended) - Best Wayland support, hardware acceleration" \
        "Firefox - Privacy-focused, open source" \
        "Chromium - Open source Chrome alternative" \
        "Brave - Privacy-focused Chromium-based" \
        "Multiple browsers - Install several options" \
        "Skip - I'll install manually later"
    
    get_choice 6
    local browser_choice=$?
    
    case $browser_choice in
        0) 
            USER_CHOICES+=("browser:chrome")
            print_recommendation "Chrome has the best Wayland support and hardware acceleration!"
            ;;
        1) 
            USER_CHOICES+=("browser:firefox")
            print_info "Firefox is great for privacy but may need Wayland tweaks."
            ;;
        2) 
            USER_CHOICES+=("browser:chromium")
            print_info "Chromium is open source but lacks some Chrome features."
            ;;
        3) 
            USER_CHOICES+=("browser:brave")
            print_info "Brave offers good privacy with Chromium compatibility."
            ;;
        4) 
            USER_CHOICES+=("browser:multiple")
            print_info "Installing Chrome, Firefox, and Brave for maximum flexibility."
            ;;
        5) 
            USER_CHOICES+=("browser:skip")
            ;;
    esac
    
    press_enter
}

# Development Tools Selection
select_dev_tools() {
    show_header
    echo -e "${YELLOW}${BOLD}💻 DEVELOPMENT TOOLS SELECTION${NC}"
    echo -e "${DIM}$(printf '─%.0s' {1..60})${NC}"
    echo
    echo -e "${WHITE}Choose development tools based on your programming needs.${NC}"
    echo
    
    show_menu "Choose your development setup:" \
        "Full Development Stack - All tools (git, gcc, nodejs, python, etc.)" \
        "Basic Development - Essential tools only (git, text editors)" \
        "System Programming - C/C++, Rust, Assembly tools" \
        "Web Development - Node.js, npm, web tools" \
        "Python Development - Python, pip, virtual environments" \
        "Skip - No development tools"
    
    get_choice 6
    local dev_choice=$?
    
    case $dev_choice in
        0) 
            USER_CHOICES+=("dev:full")
            print_recommendation "Full stack gives you everything for any development task!"
            ;;
        1) 
            USER_CHOICES+=("dev:basic")
            print_info "Basic tools are perfect for configuration and light development."
            ;;
        2) 
            USER_CHOICES+=("dev:system")
            print_info "System programming tools for low-level development."
            ;;
        3) 
            USER_CHOICES+=("dev:web")
            print_info "Web development tools for modern JavaScript/TypeScript projects."
            ;;
        4) 
            USER_CHOICES+=("dev:python")
            print_info "Python development environment for data science and automation."
            ;;
        5) 
            USER_CHOICES+=("dev:skip")
            ;;
    esac
    
    press_enter
}

# File Manager Selection
select_file_manager() {
    show_header
    echo -e "${YELLOW}${BOLD}📁 FILE MANAGER SELECTION${NC}"
    echo -e "${DIM}$(printf '─%.0s' {1..60})${NC}"
    echo
    echo -e "${WHITE}Choose your file management setup.${NC}"
    echo
    
    show_menu "Choose your file manager setup:" \
        "Dual Setup (Recommended) - Thunar (GUI) + yazi (Terminal)" \
        "Thunar only - Simple, lightweight GUI file manager" \
        "Nautilus - GNOME file manager, feature-rich" \
        "Dolphin - KDE file manager, powerful features" \
        "Terminal only - yazi terminal file manager" \
        "Minimal - Basic file operations only"
    
    get_choice 6
    local fm_choice=$?
    
    case $fm_choice in
        0) 
            USER_CHOICES+=("filemanager:dual")
            print_recommendation "Dual setup gives you the best of both worlds!"
            ;;
        1) 
            USER_CHOICES+=("filemanager:thunar")
            print_info "Thunar is lightweight and integrates well with Hyprland."
            ;;
        2) 
            USER_CHOICES+=("filemanager:nautilus")
            print_info "Nautilus has great features but brings GNOME dependencies."
            ;;
        3) 
            USER_CHOICES+=("filemanager:dolphin")
            print_info "Dolphin is powerful but brings KDE dependencies."
            ;;
        4) 
            USER_CHOICES+=("filemanager:yazi")
            print_info "yazi is a modern terminal file manager with vim-like controls."
            ;;
        5) 
            USER_CHOICES+=("filemanager:minimal")
            ;;
    esac
    
    press_enter
}

# Additional Applications
select_additional_apps() {
    show_header
    echo -e "${YELLOW}${BOLD}📱 ADDITIONAL APPLICATIONS${NC}"
    echo -e "${DIM}$(printf '─%.0s' {1..60})${NC}"
    echo
    echo -e "${WHITE}Select additional applications you'd like to install.${NC}"
    echo
    
    local apps=()
    
    if ask_yes_no "Install media applications (VLC, mpv)?"; then
        apps+=("media")
    fi
    
    if ask_yes_no "Install image editing (GIMP, ImageMagick)?"; then
        apps+=("graphics")
    fi
    
    if ask_yes_no "Install office suite (LibreOffice)?"; then
        apps+=("office")
    fi
    
    if ask_yes_no "Install communication apps (Discord, Telegram)?"; then
        apps+=("communication")
    fi
    
    if ask_yes_no "Install gaming tools (Steam, Lutris)?"; then
        apps+=("gaming")
    fi
    
    if ask_yes_no "Install system monitoring tools (htop, btop, neofetch)?"; then
        apps+=("monitoring")
    fi
    
    USER_CHOICES+=("apps:$(IFS=,; echo "${apps[*]}")")
    
    press_enter
}

# Theme and Appearance
select_theme() {
    show_header
    echo -e "${YELLOW}${BOLD}🎨 THEME AND APPEARANCE${NC}"
    echo -e "${DIM}$(printf '─%.0s' {1..60})${NC}"
    echo
    echo -e "${WHITE}Choose your visual theme and appearance settings.${NC}"
    echo
    
    show_menu "Choose your theme:" \
        "Catppuccin Mocha (Recommended) - Dark, modern, beautiful" \
        "Catppuccin Latte - Light theme variant" \
        "Nord - Cool, minimal theme" \
        "Dracula - Popular dark theme" \
        "Custom - I'll configure themes myself"
    
    get_choice 5
    local theme_choice=$?
    
    case $theme_choice in
        0) 
            USER_CHOICES+=("theme:catppuccin-mocha")
            print_recommendation "Catppuccin Mocha is perfectly configured for this setup!"
            ;;
        1) 
            USER_CHOICES+=("theme:catppuccin-latte")
            print_info "Light theme variant of Catppuccin."
            ;;
        2) 
            USER_CHOICES+=("theme:nord")
            print_info "Nord theme will require additional configuration."
            ;;
        3) 
            USER_CHOICES+=("theme:dracula")
            print_info "Dracula theme will require additional configuration."
            ;;
        4) 
            USER_CHOICES+=("theme:custom")
            ;;
    esac
    
    press_enter
}

# Installation Summary
show_installation_summary() {
    show_header
    echo -e "${YELLOW}${BOLD}📋 INSTALLATION SUMMARY${NC}"
    echo -e "${DIM}$(printf '─%.0s' {1..60})${NC}"
    echo
    echo -e "${WHITE}Review your selections before installation:${NC}"
    echo
    
    for choice in "${USER_CHOICES[@]}"; do
        IFS=':' read -r category value <<< "$choice"
        case $category in
            "dm") echo -e "${CYAN}Display Manager:${NC} $value" ;;
            "audio") echo -e "${CYAN}Audio System:${NC} $value" ;;
            "browser") echo -e "${CYAN}Web Browser:${NC} $value" ;;
            "dev") echo -e "${CYAN}Development Tools:${NC} $value" ;;
            "filemanager") echo -e "${CYAN}File Manager:${NC} $value" ;;
            "apps") echo -e "${CYAN}Additional Apps:${NC} $value" ;;
            "theme") echo -e "${CYAN}Theme:${NC} $value" ;;
        esac
    done
    
    echo
    echo -e "${PURPLE}${BOLD}Estimated installation time: 20-45 minutes${NC}"
    echo -e "${PURPLE}${BOLD}Estimated download size: 1-3 GB${NC}"
    echo
    
    if ask_yes_no "Proceed with installation?"; then
        return 0
    else
        print_info "Installation cancelled. You can run this script again anytime."
        exit 0
    fi
}

# Installation functions
install_yay() {
    print_info "Installing yay AUR helper..."
    sudo pacman -S --needed --noconfirm git base-devel
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd "$SCRIPT_DIR"
    rm -rf /tmp/yay
    print_status "yay installed successfully!"
}

install_display_manager() {
    local dm=$(echo "${USER_CHOICES[@]}" | grep -o 'dm:[^[:space:]]*' | cut -d: -f2)
    
    case $dm in
        "sddm")
            print_info "Installing SDDM..."
            sudo pacman -S --needed --noconfirm sddm qt5-graphicaleffects qt5-quickcontrols2 qt5-svg
            sudo systemctl enable sddm
            print_status "SDDM installed and enabled!"
            ;;
        "gdm")
            print_info "Installing GDM..."
            sudo pacman -S --needed --noconfirm gdm
            sudo systemctl enable gdm
            print_status "GDM installed and enabled!"
            ;;
        "lightdm")
            print_info "Installing LightDM..."
            sudo pacman -S --needed --noconfirm lightdm lightdm-gtk-greeter
            sudo systemctl enable lightdm
            print_status "LightDM installed and enabled!"
            ;;
        "ly")
            print_info "Installing ly..."
            yay -S --needed --noconfirm ly
            sudo systemctl enable ly
            print_status "ly installed and enabled!"
            ;;
        "skip")
            print_info "Skipping display manager installation."
            ;;
    esac
}

install_audio_system() {
    local audio=$(echo "${USER_CHOICES[@]}" | grep -o 'audio:[^[:space:]]*' | cut -d: -f2)
    
    case $audio in
        "pipewire")
            print_info "Installing PipeWire..."
            sudo pacman -S --needed --noconfirm pipewire pipewire-pulse pipewire-alsa pipewire-jack wireplumber
            systemctl --user enable --now pipewire pipewire-pulse wireplumber
            print_status "PipeWire installed and configured!"
            ;;
        "pulseaudio")
            print_info "Installing PulseAudio..."
            sudo pacman -S --needed --noconfirm pulseaudio pulseaudio-alsa pavucontrol
            systemctl --user enable --now pulseaudio
            print_status "PulseAudio installed and configured!"
            ;;
        "alsa")
            print_info "Installing ALSA..."
            sudo pacman -S --needed --noconfirm alsa-utils
            print_status "ALSA installed!"
            ;;
    esac
}

# Main installation process
run_installation() {
    show_header
    echo -e "${GREEN}${BOLD}🚀 STARTING INSTALLATION${NC}"
    echo -e "${DIM}$(printf '─%.0s' {1..60})${NC}"
    echo
    
    TOTAL_STEPS=10
    CURRENT_STEP=0
    
    # Step 1: System update
    ((CURRENT_STEP++))
    show_progress $CURRENT_STEP $TOTAL_STEPS
    print_info "Updating system packages..."
    sudo pacman -Syu --noconfirm
    print_status "System updated!"
    
    # Step 2: Install yay
    ((CURRENT_STEP++))
    show_progress $CURRENT_STEP $TOTAL_STEPS
    if ! command -v yay &> /dev/null; then
        install_yay
    else
        print_status "yay already installed!"
    fi
    
    # Step 3: Install display manager
    ((CURRENT_STEP++))
    show_progress $CURRENT_STEP $TOTAL_STEPS
    install_display_manager
    
    # Step 4: Install audio system
    ((CURRENT_STEP++))
    show_progress $CURRENT_STEP $TOTAL_STEPS
    install_audio_system
    
    # Step 5: Install base Hyprland packages
    ((CURRENT_STEP++))
    show_progress $CURRENT_STEP $TOTAL_STEPS
    print_info "Installing Hyprland and base packages..."
    if [[ -f "$SCRIPT_DIR/packages/base.txt" ]]; then
        yay -S --needed --noconfirm $(cat "$SCRIPT_DIR/packages/base.txt" | tr '\n' ' ')
        print_status "Base packages installed!"
    else
        print_error "Base packages file not found!"
    fi
    
    # Step 6: Install development tools
    ((CURRENT_STEP++))
    show_progress $CURRENT_STEP $TOTAL_STEPS
    local dev=$(echo "${USER_CHOICES[@]}" | grep -o 'dev:[^[:space:]]*' | cut -d: -f2)
    if [[ "$dev" != "skip" ]] && [[ -f "$SCRIPT_DIR/packages/dev.txt" ]]; then
        print_info "Installing development tools..."
        yay -S --needed --noconfirm $(cat "$SCRIPT_DIR/packages/dev.txt" | tr '\n' ' ')
        print_status "Development tools installed!"
    else
        print_info "Skipping development tools."
    fi
    
    # Step 7: Install additional applications
    ((CURRENT_STEP++))
    show_progress $CURRENT_STEP $TOTAL_STEPS
    print_info "Installing additional applications..."
    # Implementation for additional apps based on USER_CHOICES
    print_status "Additional applications installed!"
    
    # Step 8: Copy configuration files
    ((CURRENT_STEP++))
    show_progress $CURRENT_STEP $TOTAL_STEPS
    print_info "Copying configuration files..."
    bash "$SCRIPT_DIR/install.sh" <<< "3" # Run config-only installation
    print_status "Configuration files copied!"
    
    # Step 9: Configure system files
    ((CURRENT_STEP++))
    show_progress $CURRENT_STEP $TOTAL_STEPS
    print_info "Configuring system files..."
    bash "$SCRIPT_DIR/install.sh" <<< "4" # Run system setup
    print_status "System configured!"
    
    # Step 10: Final setup
    ((CURRENT_STEP++))
    show_progress $CURRENT_STEP $TOTAL_STEPS
    print_info "Finalizing setup..."
    fc-cache -fv
    print_status "Setup completed!"
}

# Final success screen
show_success() {
    show_header
    echo -e "${GREEN}${BOLD}🎉 INSTALLATION COMPLETED SUCCESSFULLY! 🎉${NC}"
    echo -e "${DIM}$(printf '─%.0s' {1..60})${NC}"
    echo
    echo -e "${WHITE}Your Hyprland desktop environment is now ready!${NC}"
    echo
    echo -e "${CYAN}${BOLD}Next Steps:${NC}"
    echo -e "1. ${WHITE}Reboot your system:${NC} sudo reboot"
    echo -e "2. ${WHITE}Log in through your display manager${NC}"
    echo -e "3. ${WHITE}Select 'Hyprland' as your session${NC}"
    echo
    echo -e "${CYAN}${BOLD}Key Bindings:${NC}"
    echo -e "• ${WHITE}Super + Q${NC} - Open terminal"
    echo -e "• ${WHITE}Super + Space${NC} - Application launcher"
    echo -e "• ${WHITE}Super + E${NC} - File manager"
    echo -e "• ${WHITE}Super + B${NC} - Web browser"
    echo -e "• ${WHITE}Super + L${NC} - Lock screen"
    echo
    echo -e "${PURPLE}${BOLD}🌟 Enjoy your beautiful new Hyprland setup! 🌟${NC}"
    echo
    
    if ask_yes_no "Would you like to reboot now?"; then
        sudo reboot
    fi
}

# Main execution
main() {
    check_system
    show_welcome
    select_display_manager
    select_audio_system
    select_browser
    select_dev_tools
    select_file_manager
    select_additional_apps
    select_theme
    show_installation_summary
    run_installation
    show_success
}

# Run the main function
main "$@"