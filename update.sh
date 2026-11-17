#!/bin/bash
# update.sh — bump flake inputs (nixpkgs, home-manager, overlays) and re-apply
# the home-manager configuration. Extra args are passed to home-manager switch.
set -euo pipefail

cd "$(dirname "$0")"

echo "→ Updating flake.lock inputs"
nix flake update

echo "→ Applying home-manager configuration"
home-manager switch --impure --flake .#default "$@"

echo "✓ Done. Optional cleanup of old generations: nix-collect-garbage -d"
