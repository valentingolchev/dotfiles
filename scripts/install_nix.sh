#!/bin/bash
# Install Nix using the NixOS experimental installer (SELinux-compatible)
# https://github.com/NixOS/nix-installer
set -e

# Idempotent: skips the install if /nix already exists.

if command -v nix >/dev/null 2>&1 || [ -d /nix ]; then
  echo "Nix is already installed. Nothing to do."
  exit 0
fi

if [ "$(id -u)" -eq 0 ]; then
  echo "Run this script as a regular user, not as root." >&2
  exit 1
fi

echo "Installing Nix (multi-user, SELinux-compatible)..."
curl -sSfL https://artifacts.nixos.org/nix-installer | sh -s -- install linux --no-confirm

echo
echo "Nix installed. Start a new shell (or run:"
echo "  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh)"
echo "then verify with: nix --version"
