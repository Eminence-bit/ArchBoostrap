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
        log_success "yay already installed, skipping"
        return 0
    fi
    
    log_info "Installing yay AUR helper..."
    
    # Check if base-devel and git are installed
    local deps_to_install=()
    for dep in git base-devel; do
        if ! pacman -Qi "$dep" &>/dev/null; then
            deps_to_install+=("$dep")
        fi
    done
    
    # Install dependencies if needed
    if [[ ${#deps_to_install[@]} -gt 0 ]]; then
        log_info "Installing yay dependencies: ${deps_to_install[*]}"
        sudo pacman -S --needed --noconfirm "${deps_to_install[@]}"
    else
        log_info "yay dependencies already installed"
    fi
    
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
    
    log_info "Checking $description..."
    
    # Read packages, remove comments and empty lines
    local all_packages
    all_packages=$(grep -v '^#' "$package_file" | grep -v '^$' | tr '\n' ' ')
    
    if [[ -z "$all_packages" ]]; then
        log_info "No packages found in $package_file"
        return 0
    fi
    
    # Check which packages are already installed
    local packages_to_install=()
    local already_installed=()
    
    for package in $all_packages; do
        # Check if package is installed (works for both pacman and AUR packages)
        if pacman -Qi "$package" &>/dev/null; then
            already_installed+=("$package")
        else
            packages_to_install+=("$package")
        fi
    done
    
    # Report already installed packages
    if [[ ${#already_installed[@]} -gt 0 ]]; then
        log_info "Already installed (${#already_installed[@]} packages): ${already_installed[*]:0:5}$([ ${#already_installed[@]} -gt 5 ] && echo "...")"
    fi
    
    # Install missing packages
    if [[ ${#packages_to_install[@]} -gt 0 ]]; then
        log_info "Installing ${#packages_to_install[@]} missing packages for $description..."
        yay -S --needed --noconfirm "${packages_to_install[@]}"
        log_success "$description - ${#packages_to_install[@]} new packages installed"
    else
        log_success "$description - all packages already installed, skipping"
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
        "hypr/hyprland.conf:$HOME/.config/hypr/hyprland.conf"
        "waybar:$HOME/.config/waybar"
        "wofi:$HOME/.config/wofi"
        "kitty:$HOME/.config/kitty"
        "swaylock:$HOME/.config/swaylock"
        "nvim:$HOME/.config/nvim"
        "mako:$HOME/.config/mako"
    )
    
    for config in "${configs[@]}"; do
        local src_path="${config%%:*}"
        local dest_path="${config##*:}"
        local full_src_path="$SCRIPT_DIR/$src_path"
        
        # Handle single file vs directory
        if [[ "$src_path" == *".conf" ]]; then
            # Single file
            if [[ ! -f "$full_src_path" ]]; then
                log_error "Source file not found: $full_src_path"
                continue
            fi
            
            # Remove existing file if it's not a symlink
            if [[ -f "$dest_path" && ! -L "$dest_path" ]]; then
                log_info "Backing up existing config: $dest_path -> $dest_path.backup.$(date +%s)"
                mv "$dest_path" "$dest_path.backup.$(date +%s)"
            elif [[ -L "$dest_path" ]]; then
                log_info "Removing existing symlink: $dest_path"
                rm "$dest_path"
            fi
            
            # Create symlink
            ln -sf "$full_src_path" "$dest_path"
            log_info "Symlinked: $full_src_path -> $dest_path"
        else
            # Directory
            if [[ ! -d "$full_src_path" ]]; then
                log_error "Source directory not found: $full_src_path"
                continue
            fi
            
            # Remove existing directory if it's not a symlink
            if [[ -d "$dest_path" && ! -L "$dest_path" ]]; then
                log_info "Backing up existing config: $dest_path -> $dest_path.backup.$(date +%s)"
                mv "$dest_path" "$dest_path.backup.$(date +%s)"
            elif [[ -L "$dest_path" ]]; then
                log_info "Removing existing symlink: $dest_path"
                rm "$dest_path"
            fi
            
            # Create symlink
            ln -sf "$full_src_path" "$dest_path"
            log_info "Symlinked: $full_src_path -> $dest_path"
        fi
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
        if [[ -f "/etc/environment" ]] && cmp -s "$SCRIPT_DIR/system/environment" "/etc/environment"; then
            log_info "Environment file already up to date"
        else
            sudo cp "$SCRIPT_DIR/system/environment" /etc/environment
            log_info "Environment variables configured"
        fi
    else
        log_error "Environment file not found: $SCRIPT_DIR/system/environment"
    fi
    
    # XDG portal configuration
    if [[ -f "$SCRIPT_DIR/system/xdg-portal.conf" ]]; then
        sudo mkdir -p /usr/share/xdg-desktop-portal/
        local portal_dest="/usr/share/xdg-desktop-portal/xdg-portal.conf"
        if [[ -f "$portal_dest" ]] && cmp -s "$SCRIPT_DIR/system/xdg-portal.conf" "$portal_dest"; then
            log_info "XDG portal config already up to date"
        else
            sudo cp "$SCRIPT_DIR/system/xdg-portal.conf" "$portal_dest"
            log_info "XDG portal configured"
        fi
    else
        log_error "XDG portal config not found: $SCRIPT_DIR/system/xdg-portal.conf"
    fi
    
    log_success "System files checked and updated"
}

# Enable system services
enable_services() {
    log_info "Checking and enabling system services..."
    
    # Audio services (user-level)
    local user_services=("pipewire" "pipewire-pulse" "wireplumber")
    for service in "${user_services[@]}"; do
        if systemctl --user list-unit-files | grep -q "^$service.service"; then
            if systemctl --user is-enabled "$service" &>/dev/null; then
                log_info "User service already enabled: $service"
            else
                systemctl --user enable --now "$service" 2>/dev/null || {
                    log_info "Could not enable $service (may already be running)"
                }
                log_info "Enabled user service: $service"
            fi
        else
            log_info "Service not available: $service"
        fi
    done
    
    # System services
    local system_services=("NetworkManager" "bluetooth")
    for service in "${system_services[@]}"; do
        if systemctl list-unit-files | grep -q "^$service.service"; then
            if systemctl is-enabled "$service" &>/dev/null; then
                log_info "System service already enabled: $service"
            else
                sudo systemctl enable --now "$service"
                log_info "Enabled system service: $service"
            fi
        else
            log_info "Service not available: $service"
        fi
    done
    
    log_success "System services configured"
}

# Clean up conflicting packages
cleanup_conflicts() {
    log_info "Checking for conflicting packages..."
    
    local conflicting_packages=("xdg-desktop-portal-gnome" "xdg-desktop-portal-gtk")
    local found_conflicts=()
    
    for package in "${conflicting_packages[@]}"; do
        if pacman -Qi "$package" &>/dev/null; then
            found_conflicts+=("$package")
        fi
    done
    
    if [[ ${#found_conflicts[@]} -eq 0 ]]; then
        log_success "No conflicting packages found"
        return 0
    fi
    
    log_info "Found conflicting packages: ${found_conflicts[*]}"
    for package in "${found_conflicts[@]}"; do
        log_info "Removing conflicting package: $package"
        yay -R --noconfirm "$package" || {
            log_info "Could not remove $package (may have dependencies)"
        }
    done
    
    log_success "Conflicting packages cleaned up"
}

# Clean up residue files after configuration updates
cleanup_residue_files() {
    log_info "Cleaning up residue and outdated configuration files..."
    
    local cleaned_count=0
    
    # Clean up old modular Hyprland config files (now using single file)
    local old_hypr_files=(
        "$HOME/.config/hypr/env.conf"
        "$HOME/.config/hypr/input.conf"
        "$HOME/.config/hypr/binds.conf"
        "$HOME/.config/hypr/layout.conf"
        "$HOME/.config/hypr/rules.conf"
        "$HOME/.config/hypr/animations.conf"
        "$HOME/.config/hypr/decoration.conf"
        "$HOME/.config/hypr/gestures.conf"
    )
    
    for old_file in "${old_hypr_files[@]}"; do
        if [[ -f "$old_file" && ! -L "$old_file" ]]; then
            rm -f "$old_file"
            log_info "Removed old modular config: $(basename "$old_file")"
            ((cleaned_count++))
        fi
    done
    
    # Clean up old backup files (older than 30 days)
    if [[ -d "$HOME/.config" ]]; then
        local old_backups
        old_backups=$(find "$HOME/.config" -name "*.backup.*" -type f -mtime +30 2>/dev/null || true)
        if [[ -n "$old_backups" ]]; then
            echo "$old_backups" | while read -r backup_file; do
                if [[ -f "$backup_file" ]]; then
                    rm -f "$backup_file"
                    log_info "Removed old backup: $(basename "$backup_file")"
                    ((cleaned_count++))
                fi
            done
        fi
    fi
    
    # Clean up temporary files
    local temp_patterns=(
        "$HOME/.config/*/.tmp*"
        "$HOME/.config/*/tmp.*"
        "$HOME/.config/*/*.tmp"
        "$HOME/.config/*/cache/*"
        "$HOME/.local/share/recently-used.xbel*"
    )
    
    for pattern in "${temp_patterns[@]}"; do
        for file in $pattern 2>/dev/null; do
            if [[ -f "$file" ]]; then
                rm -f "$file"
                log_info "Removed temp file: $(basename "$file")"
                ((cleaned_count++))
            fi
        done
    done
    
    # Clean up conflicting desktop entries
    local conflicting_entries=(
        "$HOME/.local/share/applications/hyprland.desktop"
        "$HOME/.local/share/applications/waybar.desktop"
        "$HOME/.config/autostart/hyprland.desktop"
    )
    
    for entry in "${conflicting_entries[@]}"; do
        if [[ -f "$entry" ]]; then
            rm -f "$entry"
            log_info "Removed conflicting desktop entry: $(basename "$entry")"
            ((cleaned_count++))
        fi
    done
    
    # Clean up old Hyprland cache and logs
    local hypr_cache_dirs=(
        "$HOME/.cache/hyprland"
        "$HOME/.local/share/hyprland"
    )
    
    for cache_dir in "${hypr_cache_dirs[@]}"; do
        if [[ -d "$cache_dir" ]]; then
            # Only remove cache files, not the directory structure
            find "$cache_dir" -type f -name "*.log" -mtime +7 -delete 2>/dev/null || true
            find "$cache_dir" -type f -name "*.cache" -delete 2>/dev/null || true
            log_info "Cleaned cache directory: $(basename "$cache_dir")"
        fi
    done
    
    # Clean up old waybar cache
    if [[ -d "$HOME/.cache/waybar" ]]; then
        rm -rf "$HOME/.cache/waybar"/*
        log_info "Cleaned waybar cache"
        ((cleaned_count++))
    fi
    
    # Clean up old wofi cache
    if [[ -d "$HOME/.cache/wofi" ]]; then
        rm -rf "$HOME/.cache/wofi"/*
        log_info "Cleaned wofi cache"
        ((cleaned_count++))
    fi
    
    # Remove broken symlinks in config directories
    local config_dirs=(
        "$HOME/.config/hypr"
        "$HOME/.config/waybar"
        "$HOME/.config/wofi"
        "$HOME/.config/kitty"
        "$HOME/.config/mako"
    )
    
    for config_dir in "${config_dirs[@]}"; do
        if [[ -d "$config_dir" ]]; then
            find "$config_dir" -type l ! -exec test -e {} \; -delete 2>/dev/null || true
        fi
    done
    
    # Clean up old font cache
    if command -v fc-cache &> /dev/null; then
        fc-cache -f &>/dev/null
        log_info "Refreshed font cache"
    fi
    
    # Clean up package cache (keep last 3 versions)
    if command -v paccache &> /dev/null; then
        paccache -rk3 &>/dev/null || true
        log_info "Cleaned package cache"
    fi
    
    # Clean up old journal logs (keep last 7 days)
    if command -v journalctl &> /dev/null; then
        sudo journalctl --vacuum-time=7d &>/dev/null || true
        log_info "Cleaned system journal logs"
    fi
    
    # Clean up user's trash
    if [[ -d "$HOME/.local/share/Trash" ]]; then
        local trash_size
        trash_size=$(du -sh "$HOME/.local/share/Trash" 2>/dev/null | cut -f1 || echo "0")
        if [[ "$trash_size" != "0" ]] && [[ "$trash_size" != "4.0K" ]]; then
            rm -rf "$HOME/.local/share/Trash"/{files,info}/* 2>/dev/null || true
            log_info "Emptied user trash ($trash_size)"
        fi
    fi
    
    # Remove old thumbnails
    if [[ -d "$HOME/.cache/thumbnails" ]]; then
        find "$HOME/.cache/thumbnails" -type f -mtime +30 -delete 2>/dev/null || true
        log_info "Cleaned old thumbnails"
    fi
    
    # Clean up old session files
    local session_patterns=(
        "/tmp/.X11-unix/X*"
        "/tmp/.ICE-unix/*"
        "$HOME/.xsession-errors*"
    )
    
    for pattern in "${session_patterns[@]}"; do
        for file in $pattern 2>/dev/null; do
            if [[ -f "$file" ]] && [[ -w "$file" ]]; then
                rm -f "$file" 2>/dev/null || true
            fi
        done
    done
    
    log_success "Cleanup completed - removed residue files and refreshed caches"
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
    
    # Update system first (but check if recently updated)
    local last_update=""
    if [[ -f "/var/log/pacman.log" ]]; then
        last_update=$(grep -E "upgraded|installed" /var/log/pacman.log | tail -1 | cut -d' ' -f1-2)
        log_info "Last package operation: $last_update"
    fi
    
    # Only update if last update was more than 1 day ago or no recent activity
    local should_update=true
    if [[ -n "$last_update" ]]; then
        local last_update_epoch=$(date -d "$last_update" +%s 2>/dev/null || echo 0)
        local current_epoch=$(date +%s)
        local day_in_seconds=86400
        
        if [[ $((current_epoch - last_update_epoch)) -lt $day_in_seconds ]]; then
            should_update=false
            log_info "System was updated recently, skipping system update"
        fi
    fi
    
    if [[ "$should_update" == "true" ]]; then
        log_info "Updating system packages..."
        sudo pacman -Syu --noconfirm
        log_success "System updated"
    fi
    
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
    
    # Clean up residue files and refresh caches
    cleanup_residue_files
    
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