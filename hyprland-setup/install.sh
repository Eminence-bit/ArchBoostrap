#!/bin/bash

# Hyprland Setup Installation Script
# Enhanced version with interactive options

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_question() {
    echo -e "${CYAN}[QUESTION]${NC} $1"
}

# Function to ask yes/no questions
ask_yes_no() {
    while true; do
        read -p "$(echo -e "${CYAN}$1${NC} (y/n): ")" yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

# Function to check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        print_error "This script should not be run as root!"
        print_error "Run it as a regular user. It will ask for sudo when needed."
        exit 1
    fi
}

# Function to check if yay is installed
check_yay() {
    if ! command -v yay &> /dev/null; then
        print_warning "yay (AUR helper) is not installed."
        if ask_yes_no "Would you like to install yay?"; then
            install_yay
        else
            print_error "yay is required for this script. Exiting."
            exit 1
        fi
    else
        print_status "yay is already installed."
    fi
}

# Function to install yay
install_yay() {
    print_status "Installing yay..."
    sudo pacman -S --needed git base-devel
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ~
    rm -rf /tmp/yay
    print_status "yay installed successfully!"
}

# Function to install packages
install_packages() {
    local package_file=$1
    local description=$2
    
    if [[ -f "$package_file" ]]; then
        print_status "Installing $description..."
        yay -S --needed --noconfirm $(cat "$package_file" | tr '\n' ' ')
        print_status "$description installed successfully!"
    else
        print_warning "$package_file not found. Skipping $description installation."
    fi
}

# Function to copy configuration files
copy_configs() {
    print_status "Creating configuration directories..."
    mkdir -p ~/.config/{hypr,waybar,wofi,kitty,swaylock,nvim,mako}
    mkdir -p ~/.local/bin

    print_status "Copying configuration files..."
    
    # Check if directories exist before copying
    for dir in hypr waybar wofi kitty swaylock nvim mako; do
        if [[ -d "$dir" ]]; then
            cp -r "$dir"/* ~/.config/"$dir"/
            print_status "Copied $dir configuration"
        else
            print_warning "$dir directory not found. Skipping."
        fi
    done

    # Copy scripts
    if [[ -d "scripts" ]]; then
        print_status "Installing scripts..."
        cp scripts/* ~/.local/bin/
        chmod +x ~/.local/bin/*.sh
        print_status "Scripts installed successfully!"
    else
        print_warning "scripts directory not found. Skipping."
    fi
}

# Function to install system files
install_system_files() {
    print_status "Installing system configurations..."
    
    if [[ -f "system/environment" ]]; then
        sudo cp system/environment /etc/environment
        print_status "Environment variables configured"
    else
        print_warning "system/environment not found. Skipping."
    fi
    
    if [[ -f "system/xdg-portal.conf" ]]; then
        sudo mkdir -p /usr/share/xdg-desktop-portal/
        sudo cp system/xdg-portal.conf /usr/share/xdg-desktop-portal/
        print_status "XDG portal configured"
    else
        print_warning "system/xdg-portal.conf not found. Skipping."
    fi
}

# Function to enable services
enable_services() {
    print_status "Enabling system services..."
    
    # Enable audio services
    systemctl --user enable --now pipewire pipewire-pulse wireplumber 2>/dev/null || {
        print_warning "Could not enable audio services. They may already be running."
    }
    
    # Enable bluetooth if available
    if systemctl list-unit-files | grep -q bluetooth.service; then
        print_status "Enabling Bluetooth service..."
        sudo systemctl enable --now bluetooth.service
    else
        print_warning "Bluetooth service not available. Skipping."
    fi
    
    # Enable NetworkManager if not already enabled
    if ! systemctl is-enabled NetworkManager &>/dev/null; then
        print_status "Enabling NetworkManager..."
        sudo systemctl enable --now NetworkManager
    fi
}

# Function to disable conflicting portals
disable_conflicting_portals() {
    print_status "Cleaning up conflicting XDG portals..."
    
    # Remove conflicting portals
    conflicting_portals=("xdg-desktop-portal-gnome" "xdg-desktop-portal-gtk")
    for portal in "${conflicting_portals[@]}"; do
        if pacman -Qi "$portal" &>/dev/null; then
            if ask_yes_no "Remove conflicting portal $portal?"; then
                yay -R --noconfirm "$portal" || print_warning "Could not remove $portal"
            fi
        fi
    done
}

# Function to set up fonts
setup_fonts() {
    print_status "Refreshing font cache..."
    fc-cache -fv
    print_status "Font cache refreshed!"
}

# Main menu function
show_menu() {
    clear
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║                    Hyprland Setup Script                    ║${NC}"
    echo -e "${PURPLE}║                  Catppuccin Mocha Theme                     ║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}Please select installation options:${NC}"
    echo ""
    echo "1. Full installation (recommended for new setups)"
    echo "2. Install packages only"
    echo "3. Copy configuration files only"
    echo "4. Install system files and enable services only"
    echo "5. Custom installation (choose components)"
    echo "6. Exit"
    echo ""
}

# Function for full installation
full_installation() {
    print_status "Starting full Hyprland installation..."
    
    check_yay
    
    if ask_yes_no "Install base packages (hyprland, waybar, etc.)?"; then
        install_packages "packages/base.txt" "base packages"
    fi
    
    if ask_yes_no "Install development packages (neovim, git, etc.)?"; then
        install_packages "packages/dev.txt" "development packages"
    fi
    
    if [[ -f "packages/optional.txt" ]] && ask_yes_no "Install optional packages?"; then
        install_packages "packages/optional.txt" "optional packages"
    fi
    
    copy_configs
    install_system_files
    enable_services
    disable_conflicting_portals
    setup_fonts
    
    print_status "Full installation completed!"
}

# Function for custom installation
custom_installation() {
    print_status "Custom installation selected..."
    
    if ask_yes_no "Check/install yay AUR helper?"; then
        check_yay
    fi
    
    if ask_yes_no "Install base packages?"; then
        install_packages "packages/base.txt" "base packages"
    fi
    
    if ask_yes_no "Install development packages?"; then
        install_packages "packages/dev.txt" "development packages"
    fi
    
    if [[ -f "packages/optional.txt" ]] && ask_yes_no "Install optional packages?"; then
        install_packages "packages/optional.txt" "optional packages"
    fi
    
    if ask_yes_no "Copy configuration files?"; then
        copy_configs
    fi
    
    if ask_yes_no "Install system files?"; then
        install_system_files
    fi
    
    if ask_yes_no "Enable system services?"; then
        enable_services
    fi
    
    if ask_yes_no "Clean up conflicting XDG portals?"; then
        disable_conflicting_portals
    fi
    
    if ask_yes_no "Refresh font cache?"; then
        setup_fonts
    fi
    
    print_status "Custom installation completed!"
}

# Function to show final instructions
show_final_instructions() {
    echo ""
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                     Installation Complete!                  ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo "1. Log out and log back in (or reboot) for environment changes to take effect"
    echo "2. Start Hyprland from your display manager or run 'Hyprland' from TTY"
    echo ""
    echo -e "${CYAN}Key bindings:${NC}"
    echo "• Super + Q: Open terminal (kitty)"
    echo "• Super + Space: Application launcher (wofi)"
    echo "• Super + E: File manager (thunar)"
    echo "• Super + Shift + E: Terminal file manager (yazi)"
    echo "• Super + B: Web browser (google-chrome)"
    echo "• Super + L: Lock screen (swaylock)"
    echo "• Super + S: Screenshot with editing (grim + slurp + swappy)"
    echo ""
    echo -e "${PURPLE}Enjoy your new Hyprland setup with Catppuccin Mocha theme! 🎉${NC}"
}

# Main script execution
main() {
    check_root
    
    while true; do
        show_menu
        read -p "Enter your choice (1-6): " choice
        
        case $choice in
            1)
                full_installation
                show_final_instructions
                break
                ;;
            2)
                check_yay
                if ask_yes_no "Install base packages?"; then
                    install_packages "packages/base.txt" "base packages"
                fi
                if ask_yes_no "Install development packages?"; then
                    install_packages "packages/dev.txt" "development packages"
                fi
                if [[ -f "packages/optional.txt" ]] && ask_yes_no "Install optional packages?"; then
                    install_packages "packages/optional.txt" "optional packages"
                fi
                print_status "Package installation completed!"
                ;;
            3)
                copy_configs
                print_status "Configuration files copied!"
                ;;
            4)
                install_system_files
                enable_services
                print_status "System setup completed!"
                ;;
            5)
                custom_installation
                show_final_instructions
                break
                ;;
            6)
                print_status "Exiting..."
                exit 0
                ;;
            *)
                print_error "Invalid option. Please choose 1-6."
                sleep 2
                ;;
        esac
        
        if [[ $choice != 1 && $choice != 5 ]]; then
            echo ""
            read -p "Press Enter to return to menu..."
        fi
    done
}

# Run the main function
main "$@"