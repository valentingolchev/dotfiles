#!/bin/bash
# Dotfiles setup: Nix → home-manager → packages → stow
# Each step checks if it's needed before running.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${YELLOW}→${NC} $1"; }
log_ok()   { echo -e "${GREEN}✓${NC} $1"; }
log_err()  { echo -e "${RED}✗${NC} $1" >&2; }

# ============================================================================
# Step 1: Install Nix
# ============================================================================
step1_install_nix() {
  log_info "Step 1/5: Nix"

  if command -v nix >/dev/null 2>&1 || [ -d /nix ]; then
    log_ok "Nix already installed"
    return 0
  fi

  log_info "Installing Nix (multi-user, SELinux-compatible)..."
  # NixOS experimental installer: Rust-based, SELinux support, flakes enabled
  curl -sSfL https://artifacts.nixos.org/nix-installer | sh -s -- install linux --no-confirm

  # Source nix for current shell
  if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
    # shellcheck disable=SC1091
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  fi

  if ! command -v nix >/dev/null 2>&1; then
    log_err "Nix installation failed or not in PATH"
    log_err "Start a new shell and run this script again"
    exit 1
  fi

  log_ok "Nix installed ($(nix --version 2>/dev/null || echo 'version unknown'))"
}

# ============================================================================
# Step 2: Install home-manager
# ============================================================================
step2_install_home_manager() {
  log_info "Step 2/5: home-manager"

  if command -v home-manager >/dev/null 2>&1; then
    log_ok "home-manager already installed ($(home-manager --version))"
    return 0
  fi

  # home-manager will be bootstrapped by the switch command in step 3
  log_ok "home-manager will be installed in next step"
}

# ============================================================================
# Step 3: Install packages via home-manager
# ============================================================================
step3_install_packages() {
  log_info "Step 3/5: Packages (home-manager)"

  if [ ! -f flake.nix ]; then
    log_err "flake.nix not found in $SCRIPT_DIR"
    exit 1
  fi

  if command -v home-manager >/dev/null 2>&1; then
    log_info "Running: home-manager switch --impure --flake .#default"
    if ! home-manager switch --impure --flake .#default; then
      log_err "home-manager switch failed"
      exit 1
    fi
  else
    log_info "Bootstrapping home-manager and applying config..."
    if ! nix run github:nix-community/home-manager -- switch --impure --flake .#default; then
      log_err "home-manager bootstrap failed"
      exit 1
    fi
  fi

  log_ok "Packages installed"
}

# ============================================================================
# Step 3.5: Fix shell symlink (Nix zsh → /usr/bin/zsh)
# ============================================================================
step3b_fix_shell() {
  log_info "Step 4/5: Fix shell symlink"

  # Only on Linux
  if [ "$(uname -s)" != "Linux" ]; then
    return 0
  fi

  # Check if zsh is installed via Nix
  if ! command -v zsh >/dev/null 2>&1; then
    log_info "zsh not installed, skipping shell fix"
    return 0
  fi

  local nix_zsh
  nix_zsh=$(readlink -f "$(which zsh)")

  # If /usr/bin/zsh doesn't exist, create symlink
  if [ ! -e /usr/bin/zsh ]; then
    log_info "Creating symlink: /usr/bin/zsh → $nix_zsh"
    sudo ln -sf "$nix_zsh" /usr/bin/zsh
    log_ok "Shell symlink created"
  # If /usr/bin/zsh exists and is not our symlink, warn
  elif [ "$(readlink -f /usr/bin/zsh 2>/dev/null)" != "$nix_zsh" ]; then
    log_info "/usr/bin/zsh exists (system zsh), leaving as-is"
  else
    log_ok "/usr/bin/zsh already points to Nix zsh"
  fi
}

# ============================================================================
# Step 4: Stow dotfiles based on installed packages
# ============================================================================
step4_stow_dotfiles() {
  log_info "Step 5/5: Stow dotfiles"

  local stow_dirs=()

  # Check if package is installed, add corresponding dotfile dir
  check_pkg() {
    local pkg="$1"
    local dir="$2"
    if command -v "$pkg" >/dev/null 2>&1; then
      if [ -d "$dir" ]; then
        stow_dirs+=("$dir")
        echo -e "  ${GREEN}✓${NC} $dir (found: $pkg)"
      fi
    else
      echo -e "  ${YELLOW}·${NC} $dir (skipped: $pkg not found)"
    fi
  }

  # Package → dotfile directory mappings
  check_pkg "nvim" "nvim"
  check_pkg "kitty" "kitty"
  check_pkg "foot" "foot"
  check_pkg "zsh" "zsh"
  check_pkg "bat" "bat"
  check_pkg "fzf" "fzf"
  check_pkg "rg" "ripgrep"        # ripgrep command is 'rg'
  check_pkg "fastfetch" "fastfetch"
  check_pkg "hyprland" "hyperland"  # dir is 'hyperland', cmd is 'hyprland'

  # Fonts (check for fontconfig)
  if command -v fc-list >/dev/null 2>&1 && [ -d "fonts" ]; then
    stow_dirs+=("fonts")
    echo -e "  ${GREEN}✓${NC} fonts (found: fontconfig)"
  else
    echo -e "  ${YELLOW}·${NC} fonts (skipped: fontconfig not found)"
  fi

  # Always stow (no package check needed)
  for dir in claude opencode bin idea; do
    if [ -d "$dir" ]; then
      stow_dirs+=("$dir")
      echo -e "  ${GREEN}✓${NC} $dir"
    fi
  done

  if [ ${#stow_dirs[@]} -eq 0 ]; then
    log_err "No dotfiles to stow"
    return 1
  fi

  log_info "Stowing: ${stow_dirs[*]}"

  # Backup conflicts by renaming with .backup-YYYYMMDD postfix
  # For directories, only back up clashing files inside, not the entire folder
  local backup_suffix=".backup-$(date +%Y%m%d)"
  local has_conflicts=false

  for dir in "${stow_dirs[@]}"; do
    local conflicts
    # Match stow's conflict format: "  * existing target is not owned by stow: <path>"
    conflicts=$(stow --no-folding -n -t "$HOME" "$dir" 2>&1 | awk '/existing target is not owned by stow:/ { print $NF }' || true)
    if [ -n "$conflicts" ]; then
      has_conflicts=true
      while IFS= read -r target; do
        [ -z "$target" ] && continue
        # Make absolute path if relative
        case "$target" in
          /*) ;;
          *) target="$HOME/$target" ;;
        esac

        if [ -d "$target" ] && [ ! -L "$target" ]; then
          # It's a directory - only back up clashing files inside, not the entire folder
          # Find corresponding dotfiles directory
          local rel_path="${target#"$HOME"/}"
          local dotfiles_dir="$SCRIPT_DIR/$dir/$rel_path"
          if [ -d "$dotfiles_dir" ]; then
            # Check each file in dotfiles dir for conflicts in target
            while IFS= read -r -d '' dotfile; do
              local rel_file="${dotfile#"$dotfiles_dir"/}"
              local target_file="$target/$rel_file"
              if [ -e "$target_file" ] && [ ! -L "$target_file" ]; then
                mv "$target_file" "${target_file}${backup_suffix}"
                log_info "  Backed up: $target_file → ${target_file}${backup_suffix}"
              fi
            done < <(find "$dotfiles_dir" -type f -print0)
          fi
        elif [ -e "$target" ] || [ -L "$target" ]; then
          # It's a file or symlink - back it up
          mv "$target" "${target}${backup_suffix}"
          log_info "  Backed up: $target → ${target}${backup_suffix}"
        fi
      done <<< "$conflicts"
    fi
  done

  if [ "$has_conflicts" = true ]; then
    log_ok "Conflicts backed up with ${backup_suffix} postfix"
  fi

  # Stow all directories (--no-folding: only symlink files, not directories)
  if ! stow --no-folding -t "$HOME" "${stow_dirs[@]}"; then
    log_err "Stow failed"
    return 1
  fi

  log_ok "Stowed ${#stow_dirs[@]} dotfile directories"
}

# ============================================================================
# Main
# ============================================================================
main() {
  echo "=== Dotfiles Setup ==="
  echo ""

  step1_install_nix
  echo ""

  step2_install_home_manager
  echo ""

  step3_install_packages
  echo ""

  step3b_fix_shell
  echo ""

  step4_stow_dotfiles
  echo ""

  echo "=== Setup Complete ==="
}

# Handle --help
if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
  cat <<'EOF'
Usage: ./setup.sh

Sets up dotfiles in 5 steps (each step checks if needed):
  1. Install Nix (if not installed)
  2. Check home-manager (bootstrapped in step 3 if needed)
  3. Install packages via home-manager (home.nix)
  4. Fix shell symlink (Nix zsh → /usr/bin/zsh)
  5. Stow dotfiles based on installed packages

After first run, re-running is safe (idempotent).

For manual stow with conflict backup:
  ./symlink_all.sh

Options for symlink_all.sh:
  --dry-run       Show what would be stowed
  --dirs "..."    Space-separated list of directories
  --verbose       Print extra details
EOF
  exit 0
fi

main "$@"
