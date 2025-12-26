#!/usr/bin/env bash
set -euo pipefail

confirm() {
  local response
  read -rp "$1 [y/N]: " response
  [[ "$response" == "y" || "$response" == "Y" ]]
}

print_step() {
  echo -e "\n\033[1;34m[*]\033[0m $1"
}

print_success() {
  echo -e "\033[1;32m[✓]\033[0m $1"
}

print_error() {
  echo -e "\033[1;31m[✗]\033[0m $1" >&2
