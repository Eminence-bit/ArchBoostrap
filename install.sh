#!/usr/bin/env bash
set -euo pipefail

# Source utility functions
source "$(dirname "$0")/utils.sh"

BASE_DONE="/tmp/archbootstrap_base_done"

print_header() {
  echo -e "\033[1;33m╔════════════════════════════════════════╗\033[0m"
  echo -e "\033[1;33m║\033[0m     ArchBootstrap Installation        \033[1;33m║\033[0m"
  echo -e "\033[1;33m╚════════════════════════════════════════╝\033[0m"
  echo ""
}

print_menu() {
  echo -e "\033[1;32mAvailable Installation Profiles:\033[0m"
  echo "1) Minimal (base + user)"
  echo "2) Desktop (base + user + desktop)"
  echo "3) Development (base + user + dev)"
  echo "4) Reverse Engineering (base + user + re)"
  echo "5) Full Stack (all components)"
  echo "6) Custom (select components)"
  echo "0) Exit"
  echo ""
}

run_script() {
  local script="$1"

  if [[ ! -f "$script" ]]; then
    print_error "Script not found: $script"
    return 1
  fi

  if [[ "$script" == "base.sh" && -f "$BASE_DONE" ]]; then
    print_step "base.sh already executed — skipping"
    return 0
  fi

  print_step "Running $script"
  bash "$script"

  if [[ "$script" == "base.sh" ]]; then
    touch "$BASE_DONE"
  fi

  print_success "Completed: $script"
}

main() {
  print_header

  if [[ $EUID -eq 0 ]]; then
    print_step "Running as root (required for base.sh)"
  else
    print_step "Running as user"
  fi

  while true; do
    print_menu
    read -rp "Select an option [0-6]: " choice

    case "$choice" in
      1)
        run_script "base.sh"
        run_script "user.sh"
        print_success "Minimal profile installed"
        ;;
      2)
        run_script "base.sh"
        run_script "user.sh"
        run_script "roles/desktop.sh"
        print_success "Desktop profile installed"
        ;;
      3)
        run_script "base.sh"
        run_script "user.sh"
        run_script "roles/dev.sh"
        print_success "Development profile installed"
        ;;
      4)
        run_script "base.sh"
        run_script "user.sh"
        run_script "roles/re.sh"
        print_success "Reverse engineering profile installed"
        ;;
      5)
        run_script "base.sh"
        run_script "user.sh"
        run_script "roles/desktop.sh"
        run_script "roles/dev.sh"
        run_script "roles/re.sh"
        print_success "Full stack installed"
        ;;
      6)
        print_step "Custom installation"

        confirm "Install base system?" && run_script "base.sh"
        confirm "Install user environment?" && run_script "user.sh"
        confirm "Install desktop environment?" && run_script "roles/desktop.sh"
        confirm "Install development tools?" && run_script "roles/dev.sh"
        confirm "Install reverse engineering tools?" && run_script "roles/re.sh"

        print_success "Custom installation complete"
        ;;
      0)
        echo "Exiting."
        exit 0
        ;;
      *)
        print_error "Invalid option"
        ;;
    esac

    echo ""
    read -rp "Press Enter to continue..."
  done
}

main "$@"
