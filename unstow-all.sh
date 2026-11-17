#!/bin/bash
# unstow-all.sh — remove stow symlinks for all packages now managed by
# home-manager (files/ tree in home.nix).
#
# Run this on a machine BEFORE pulling repo updates that delete the old
# stow package dirs (stow -D needs the package dir to exist). If the dirs
# are already gone, the fallback sweep below still removes the symlinks.
#
# Usage: ./unstow-all.sh
set -u

STOW_DIR="$(cd "$(dirname "$0")" && pwd)"

# packages migrated to home.nix (must match symlink_all.sh comment)
PACKAGES="bat btop eza fastfetch idea k9s ripgrep fzf yazi tinty fonts bin hypr foot kitty"

for pkg in $PACKAGES; do
  if command -v stow >/dev/null 2>&1 && [ -d "$STOW_DIR/$pkg" ]; then
    if stow --delete --no-folding -d "$STOW_DIR" -t "$HOME" "$pkg" 2>/dev/null; then
      echo "unstowed: $pkg"
    else
      echo "stow -D failed (will try fallback): $pkg"
    fi
  else
    echo "no stow/pkg dir, fallback will handle: $pkg"
  fi
done

# Fallback: delete any symlinks under $HOME that point into this repo.
echo "--- sweeping leftover symlinks pointing into $STOW_DIR"
find "$HOME" -maxdepth 6 -type l -lname "$STOW_DIR/*" -print -delete 2>/dev/null

echo "done. Now run: home-manager switch --impure --flake .#default"
