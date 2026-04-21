#!/bin/bash
set -euo pipefail

SCRIPT_NAME="$(basename "$0")"

confirm_step() {
  local prompt="$1"
  local reply

  while true; do
    read -r -p "$prompt [Y/n/q]: " reply
    case "$reply" in
      ""|[Yy]) return 0 ;;
      [Nn]) return 1 ;;
      [Qq])
        echo "Aborted by user."
        exit 0
        ;;
      *) echo "Please answer y, n, or q." ;;
    esac
  done
}

run_step() {
  local description="$1"
  shift

  if confirm_step "Run step: $description?"; then
    echo "Running: $description"
    "$@"
    echo "Done: $description"
  else
    echo "Skipped: $description"
  fi
}

if ! command -v pacman >/dev/null 2>&1; then
  echo "Error: pacman is required. This script is for Arch Linux." >&2
  exit 1
fi

if [ -r /etc/os-release ]; then
  distro_id="$(. /etc/os-release; printf '%s' "$ID")"
  if [ "$distro_id" != "arch" ]; then
    echo "Warning: detected distro '$distro_id'. This script is intended for Arch Linux." >&2
  fi
fi

echo "${SCRIPT_NAME}: interactive Arch update helper"
echo "You can skip any step or quit at any prompt."
echo

run_step "Enable NTP time sync" sudo timedatectl set-ntp true
run_step "Update archlinux-keyring" sudo pacman -Sy --needed archlinux-keyring
run_step "Run full system upgrade" sudo pacman -Syu

echo
echo "All selected steps completed."
