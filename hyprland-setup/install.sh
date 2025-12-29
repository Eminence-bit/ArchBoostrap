#!/bin/bash

# Hyprland Setup Installation Script
# Non-interactive, idempotent installation for Hyprland desktop environment
# Assumes fresh Arch Linux with Wayland-only setup

set -euo pipefail

# Logging functions
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >&2
}

log_info() {
    log "INFO: $*"
}

log_error() {
    log "ERROR: $*"
}

log_success() {
    log "SUCCESS: $*"
}

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    log_error "This script should not be run as root!"
    log_error "Run it as a regular user. It will ask for sudo when needed."
    exit 1
fi

# Check if on Arch Linux
if ! command -v pacman &> /dev/null; then
    log_error "This script is designed for Arch Linux systems only."
    exit 1
fi

# Check internet connection
log_info "Checking internet connection..."
if ! ping -c 1 archlinux.org &> /dev/null; then
    log_error "No internet connection detected. Please check your network."
    exit 1
fi
log_success "Internet connection verified"

# Install yay if not present
install_yay() {
    if command -v yay &> /dev/null; then
        log_info "yay already installed, skipping"
        return 0
    fi
    
    log_info "Installing yay AUR helper..."
    
    # Install dependencies
    sudo pacman -S --needed --noconfirm git base-devel
    
    # Clone and build yay
    local temp_dir="/tmp/yay-install-$$"
    git clone https://aur.archlinux.org/yay.git "$temp_dir"
    cd "$temp_dir"
    makepkg -si --noconfirm
    cd "$SCRIPT_DIR"
    rm -rf "$temp_dir"
    
    log_success "yay installed successfully"
}

# Install packages from file
install_packages() {
    local package_file="$1"
    local description="$2"
    
    if [[ ! -f "$package_file" ]]; then
        log_error "Package file not found: $package_file"
        return 1
    fi
    
    log_info "Installing $description..."
    
    # Read packages, remove comments and empty lines
    local packages
    packages=$(grep -v '^#' "$package_file" | grep -v '^$' | tr '\n' ' ')
    
    if [[ -n "$packages" ]]; then
        yay -S --needed --noconfirm $packages
        log_success "$description installed successfully"
    else
        log_info "No packages found in $package_file"
    fi
}

# Create necessary directories
create_directories() {
    log_info "Creating configuration directories..."
    
    local dirs=(
        "$HOME/.config/hypr"
        "$HOME/.config/waybar"
        "$HOME/.config/wofi"
        "$HOME/.config/kitty"
        "$HOME/.config/swaylock"
        "$HOME/.config/nvim"
        "$HOME/.config/mako"
        "$HOME/.local/bin"
        "$HOME/.local/share/applications"
        "$HOME/Pictures/Screenshots"
    )
    
    for dir in "${dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            mkdir -p "$dir"
            log_info "Created directory: $dir"
        else
            log_info "Directory already exists: $dir"
        fi
    done
    
    log_success "Configuration directories created"
}

# Symlink configuration files
symlink_configs() {
    log_info "Creating symlinks for configuration files..."
    
    local configs=(
        "hypr:$HOME/.config/hypr"
        "waybar:$HOME/.config/waybar"
        "wofi:$HOME/.config/wofi"
        "kitty:$HOME/.config/kitty"
        "swaylock:$HOME/.config/swaylock"
        "nvim:$HOME/.config/nvim"
        "mako:$HOME/.config/mako"
    )
    
    for config in "${configs[@]}"; do
        local src_dir="${config%%:*}"
        local dest_dir="${config##*:}"
        local src_path="$SCRIPT_DIR/$src_dir"
        
        if [[ ! -d "$src_path" ]]; then
            log_error "Source directory not found: $src_path"
            continue
        fi
        
        # Remove existing directory if it's not a symlink
        if [[ -d "$dest_dir" && ! -L "$dest_dir" ]]; then
            log_info "Backing up existing config: $dest_dir -> $dest_dir.backup.$(date +%s)"
            mv "$dest_dir" "$dest_dir.backup.$(date +%s)"
        elif [[ -L "$dest_dir" ]]; then
            log_info "Removing existing symlink: $dest_dir"
            rm "$dest_dir"
        fi
        
        # Create symlink
        ln -sf "$src_path" "$dest_dir"
        log_info "Symlinked: $src_path -> $dest_dir"
    done
    
    log_success "Configuration symlinks created"
}

# Install scripts
install_scripts() {
    log_info "Installing utility scripts..."
    
    local scripts_dir="$SCRIPT_DIR/scripts"
    
    if [[ ! -d "$scripts_dir" ]]; then
        log_error "Scripts directory not found: $scripts_dir"
        return 1
    fi
    
    for script in "$scripts_dir"/*.sh; do
        if [[ -f "$script" ]]; then
            local script_name=$(basename "$script")
            local dest_path="$HOME/.local/bin/$script_name"
            
            # Create symlink instead of copying
            ln -sf "$script" "$dest_path"
            chmod +x "$script"
            log_info "Installed script: $script_name"
        fi
    done
    
    log_success "Utility scripts installed"
}

# Install system files
install_system_files() {
    log_info "Installing system configuration files..."
    
    # Environment variables
    if [[ -f "$SCRIPT_DIR/system/environment" ]]; then
        sudo cp "$SCRIPT_DIR/system/environment" /etc/environment
        log_info "Environment variables configured"
    else
        log_error "Environment file not found: $SCRIPT_DIR/system/environment"
    fi
    
    # XDG portal configuration
    if [[ -f "$SCRIPT_DIR/system/xdg-portal.conf" ]]; then
        sudo mkdir -p /usr/share/xdg-desktop-portal/
        sudo cp "$SCRIPT_DIR/system/xdg-portal.conf" /usr/share/xdg-desktop-portal/
        log_info "XDG portal configured"
    else
        log_error "XDG portal config not found: $SCRIPT_DIR/system/xdg-portal.conf"
    fi
    
    log_success "System files installed"
}

# Enable system services
enable_services() {
    log_info "Enabling system services..."
    
    # Audio services (user-level)
    local user_services=("pipewire" "pipewire-pulse" "wireplumber")
    for service in "${user_services[@]}"; do
        if systemctl --user list-unit-files | grep -q "^$service.service"; then
            systemctl --user enable --now "$service" 2>/dev/null || {
                log_info "Service $service may already be running or not available"
            }
            log_info "Enabled user service: $service"
        else
            log_info "Service not available: $service"
        fi
    done
    
    # System services
    local system_services=("NetworkManager" "bluetooth")
    for service in "${system_services[@]}"; do
        if systemctl list-unit-files | grep -q "^$service.service"; then
            if ! systemctl is-enabled "$service" &>/dev/null; then
                sudo systemctl enable --now "$service"
                log_info "Enabled system service: $service"
            else
                log_info "Service already enabled: $service"
            fi
        else
            log_info "Service not available: $service"
        fi
    done
    
    log_success "System services configured"
}

# Clean up conflicting packages
cleanup_conflicts() {
    log_info "Cleaning up conflicting packages..."
    
    local conflicting_packages=("xdg-desktop-portal-gnome" "xdg-desktop-portal-gtk")
    
    for package in "${conflicting_packages[@]}"; do
        if pacman -Qi "$package" &>/dev/null; then
            log_info "Removing conflicting package: $package"
            yay -R --noconfirm "$package" || {
                log_info "Could not remove $package (may have dependencies)"
            }
        fi
    done
    
    log_success "Conflicting packages cleaned up"
}

# Refresh font cache
refresh_fonts() {
    log_info "Refreshing font cache..."
    fc-cache -fv &>/dev/null
    log_success "Font cache refreshed"
}

# Set environment defaults
set_environment_defaults() {
    log_info "Setting environment defaults..."
    
    # Ensure .local/bin is in PATH for current session
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        export PATH="$HOME/.local/bin:$PATH"
        log_info "Added ~/.local/bin to PATH for current session"
    fi
    
    # Set XDG environment for current session
    export XDG_CURRENT_DESKTOP=Hyprland
    export XDG_SESSION_TYPE=wayland
    export XDG_SESSION_DESKTOP=Hyprland
    
    log_success "Environment defaults set"
}

# Print next steps
print_next_steps() {
    log_success "Installation completed successfully!"
    echo
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🎉 HYPRLAND SETUP COMPLETE"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
    echo "📋 NEXT STEPS:"
    echo "1. Log out and log back in (or reboot) for environment changes to take effect"
    echo "2. Start Hyprland from TTY by running: Hyprland"
    echo "3. Or set up a display manager to auto-start Hyprland"
    echo
    echo "⌨️  KEY BINDINGS:"
    echo "• Super + Q          → Open terminal (kitty)"
    echo "• Super + Space      → Application launcher (wofi)"
    echo "• Super + E          → File manager (thunar)"
    echo "• Super + Shift + E  → Terminal file manager (yazi)"
    echo "• Super + B          → Web browser"
    echo "• Super + L          → Lock screen"
    echo "• Super + S          → Screenshot with editing"
    echo "• Super + Shift + X  → Close window"
    echo
    echo "🔧 CONFIGURATION:"
    echo "• Configs are symlinked from: $SCRIPT_DIR"
    echo "• Edit source files to modify configuration"
    echo "• Scripts installed to: ~/.local/bin/"
    echo
    echo "📚 DOCUMENTATION:"
    echo "• Hyprland Wiki: https://wiki.hyprland.org/"
    echo "• Configuration files are in ~/.config/"
    echo
    echo "🎨 THEME: Catppuccin Mocha (dark theme with beautiful colors)"
    echo
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# Main installation function
main() {
    log_info "Starting Hyprland installation..."
    log_info "Script directory: $SCRIPT_DIR"
    
    # Update system first
    log_info "Updating system packages..."
    sudo pacman -Syu --noconfirm
    log_success "System updated"
    
    # Install yay AUR helper
    install_yay
    
    # Install packages
    install_packages "$SCRIPT_DIR/packages/base.txt" "base packages"
    install_packages "$SCRIPT_DIR/packages/dev.txt" "development packages"
    
    # Install optional packages if file exists
    if [[ -f "$SCRIPT_DIR/packages/optional.txt" ]]; then
        install_packages "$SCRIPT_DIR/packages/optional.txt" "optional packages"
    fi
    
    # Create directories
    create_directories
    
    # Symlink configurations
    symlink_configs
    
    # Install scripts
    install_scripts
    
    # Install system files
    install_system_files
    
    # Enable services
    enable_services
    
    # Clean up conflicts
    cleanup_conflicts
    
    # Refresh fonts
    refresh_fonts
    
    # Set environment defaults
    set_environment_defaults
    
    # Print next steps
    print_next_steps
    
    log_success "Installation script completed successfully!"
}

# Run main function
main "$@"