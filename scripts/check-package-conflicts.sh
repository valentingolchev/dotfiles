#!/bin/bash
# Check for package conflicts between Nix/home-manager and other install methods
# Usage: ./scripts/check-package-conflicts.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors (using $'...' for proper escape sequence interpretation)
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
BLUE=$'\033[0;34m'
CYAN=$'\033[0;36m'
NC=$'\033[0m'
BOLD=$'\033[1m'

# ============================================================================
# Package definitions: "nix-name:command-name:system-package-name"
# system-package-name is used for dpkg/rpm/pacman/brew lookups
# Empty system-package-name means "skip system check"
# ============================================================================
declare -a PACKAGES=(
  # Format: "nix-name|command|system-pkg"
  "git|git|git"
  "stow|stow|stow"
  "bat|bat|bat"
  "eza|eza|eza"
  "yazi|yazi|yazi"
  "fd|fd|fd-find"
  "fzf|fzf|fzf"
  "ripgrep|rg|ripgrep"
  "zoxide|zoxide|zoxide"
  "fastfetch|fastfetch|fastfetch"
  "zsh|zsh|zsh"
  "neovim|nvim|neovim"
  "kitty|kitty|kitty"
  "mise|mise|mise"
  "wl-clipboard|wl-copy|wl-clipboard"
  "foot|foot|foot"
  "btop|btop|btop"
  "tldr|tldr|tldr"
  "whois|whois|whois"
  # Removed system packages: fontconfig, gcc, gnumake, unzip, man-db, ruby
)

# ============================================================================
# Detection functions
# ============================================================================

# Check if a command is available via Nix
is_nix_installed() {
  local cmd="$1"
  local path
  path=$(command -v "$cmd" 2>/dev/null || true)
  if [ -z "$path" ]; then
    return 1
  fi
  # Check if path contains /nix/store or .nix-profile
  [[ "$path" == *"/nix/store/"* ]] || [[ "$path" == *".nix-profile"* ]]
}

# Get the Nix path for a command
get_nix_path() {
  local cmd="$1"
  command -v "$cmd" 2>/dev/null || true
}

# Check if installed via Homebrew (macOS)
is_brew_installed() {
  local pkg="$1"
  [ -z "$pkg" ] && return 1
  command -v brew >/dev/null 2>&1 || return 1
  brew list "$pkg" >/dev/null 2>&1
}

# Check if installed via system package manager (Linux)
is_system_installed() {
  local pkg="$1"
  [ -z "$pkg" ] && return 1

  if command -v dpkg >/dev/null 2>&1; then
    # Ubuntu/Debian
    dpkg -l "$pkg" >/dev/null 2>&1 && return 0
  fi
  if command -v rpm >/dev/null 2>&1; then
    # Fedora/RHEL
    rpm -q "$pkg" >/dev/null 2>&1 && return 0
  fi
  if command -v pacman >/dev/null 2>&1; then
    # Arch
    pacman -Q "$pkg" >/dev/null 2>&1 && return 0
  fi
  return 1
}

# Get system package manager name
get_system_pkgmgr() {
  if command -v dpkg >/dev/null 2>&1; then
    echo "apt/dpkg"
  elif command -v rpm >/dev/null 2>&1; then
    if command -v dnf >/dev/null 2>&1; then
      echo "dnf/rpm"
    else
      echo "rpm"
    fi
  elif command -v pacman >/dev/null 2>&1; then
    echo "pacman"
  else
    echo "unknown"
  fi
}

# Check if command is available but not via Nix or package manager (manual install)
is_manual_installed() {
  local cmd="$1"
  local path
  path=$(command -v "$cmd" 2>/dev/null || true)
  [ -z "$path" ] && return 1

  # Not Nix
  if is_nix_installed "$cmd"; then
    return 1
  fi

  # Check common manual install locations
  [[ "$path" == "/usr/local/bin/"* ]] || \
  [[ "$path" == "/opt/"* ]] || \
  [[ "$path" == "$HOME/.local/bin/"* ]] || \
  [[ "$path" == "$HOME/bin/"* ]] || \
  [[ "$path" == "/snap/"* ]]
}

# Check if command is a mise shim
is_mise_installed() {
  local cmd="$1"
  local path
  path=$(command -v "$cmd" 2>/dev/null || true)
  [ -z "$path" ] && return 1
  # mise shims are in ~/.local/share/mise/shims/
  [[ "$path" == *"/.local/share/mise/shims/"* ]]
}

# Get mise uninstall command (remove shim)
get_mise_uninstall_cmd() {
  local cmd="$1"
  echo "rm ~/.local/share/mise/shims/$cmd"
}

# Get uninstall command for system package
get_uninstall_cmd() {
  local pkg="$1"
  local pkgmgr
  pkgmgr=$(get_system_pkgmgr)

  case "$pkgmgr" in
    "apt/dpkg")
      echo "sudo apt-get remove $pkg"
      ;;
    "dnf/rpm")
      echo "sudo dnf remove $pkg"
      ;;
    "rpm")
      echo "sudo rpm -e $pkg"
      ;;
    "pacman")
      echo "sudo pacman -R $pkg"
      ;;
    *)
      echo "# Unknown package manager, remove manually"
      ;;
  esac
}

# Get Homebrew uninstall command
get_brew_uninstall_cmd() {
  local pkg="$1"
  echo "brew uninstall $pkg"
}

# ============================================================================
# Main check
# ============================================================================
check_package() {
  local nix_name="$1"
  local cmd="$2"
  local sys_pkg="$3"

  local nix_status="not installed"
  local sys_status="not installed"
  local brew_status="not installed"
  local manual_status="not installed"
  local mise_status="not installed"
  local nix_path=""
  local cmd_path=""

  # Check if command exists at all
  if [ -n "$cmd" ] && command -v "$cmd" >/dev/null 2>&1; then
    cmd_path=$(command -v "$cmd")

    if is_nix_installed "$cmd"; then
      nix_status="installed"
      nix_path=$(get_nix_path "$cmd")
    elif is_mise_installed "$cmd"; then
      mise_status="installed"
    elif is_brew_installed "$sys_pkg"; then
      brew_status="installed"
    elif is_system_installed "$sys_pkg"; then
      sys_status="installed"
    elif is_manual_installed "$cmd"; then
      manual_status="installed"
    else
      manual_status="installed (unknown location)"
    fi
  fi

  # Check system package manager even if command not found (might be library)
  if [ "$sys_status" = "not installed" ] && is_system_installed "$sys_pkg"; then
    sys_status="installed (no command)"
  fi
  if [ "$brew_status" = "not installed" ] && is_brew_installed "$sys_pkg"; then
    brew_status="installed (no command)"
  fi

  # Determine status
  local has_conflict=false
  local status_color="$NC"
  local status_text=""

  # Count installation methods
  local count=0
  [ "$nix_status" != "not installed" ] && count=$((count + 1))
  [ "$sys_status" != "not installed" ] && count=$((count + 1))
  [ "$brew_status" != "not installed" ] && count=$((count + 1))
  [ "$manual_status" != "not installed" ] && count=$((count + 1))
  [ "$mise_status" != "not installed" ] && count=$((count + 1))

  if [ $count -eq 0 ]; then
    status_text="not installed"
    status_color="$NC"
  elif [ $count -eq 1 ]; then
    if [ "$nix_status" != "not installed" ]; then
      status_text="Nix only"
      status_color="$GREEN"
    elif [ "$mise_status" != "not installed" ]; then
      status_text="mise only"
      status_color="$CYAN"
    elif [ "$sys_status" != "not installed" ]; then
      status_text="system only"
      status_color="$YELLOW"
    elif [ "$brew_status" != "not installed" ]; then
      status_text="homebrew only"
      status_color="$YELLOW"
    else
      status_text="manual only"
      status_color="$YELLOW"
    fi
  else
    has_conflict=true
    status_text="CONFLICT ($count methods)"
    status_color="$RED"
  fi

  # Print result
  printf "  ${BOLD}%-15s${NC} " "$nix_name"
  printf "%-20s " "${status_color}${status_text}${NC}"

  if [ -n "$cmd_path" ]; then
    printf "[%s]" "$cmd_path"
  fi
  echo ""

  # Print details for conflicts or non-Nix installations
  if [ "$nix_status" != "not installed" ]; then
    echo "      ${CYAN}Nix:${NC}      $nix_path"
  fi
  if [ "$mise_status" != "not installed" ]; then
    echo "      ${CYAN}mise:${NC}     $cmd_path"
    if [ "$nix_status" != "not installed" ]; then
      echo "      ${RED}→ Disable:${NC} $(get_mise_uninstall_cmd "$cmd")"
    fi
  fi
  if [ "$sys_status" != "not installed" ]; then
    echo "      ${YELLOW}System:${NC}   $sys_status"
    if [ "$nix_status" != "not installed" ]; then
      echo "      ${RED}→ Uninstall:${NC} $(get_uninstall_cmd "$sys_pkg")"
    fi
  fi
  if [ "$brew_status" != "not installed" ]; then
    echo "      ${YELLOW}Homebrew:${NC} $brew_status"
    if [ "$nix_status" != "not installed" ]; then
      echo "      ${RED}→ Uninstall:${NC} $(get_brew_uninstall_cmd "$sys_pkg")"
    fi
  fi
  if [ "$manual_status" != "not installed" ] && [ "$nix_status" != "not installed" ]; then
    echo "      ${YELLOW}Manual:${NC}   $manual_status at $cmd_path"
    echo "      ${RED}→ Uninstall:${NC} rm $cmd_path"
  fi

  if [ "$has_conflict" = true ]; then
    echo ""
  fi

  return $([ "$has_conflict" = true ] && echo 1 || echo 0)
}

# ============================================================================
# Main
# ============================================================================
main() {
  echo ""
  echo "=== Package Conflict Check ==="
  echo "Repo: $REPO_DIR"
  echo "System package manager: $(get_system_pkgmgr)"
  echo "Homebrew: $(command -v brew >/dev/null 2>&1 && echo "yes" || echo "no")"
  echo "Nix: $(command -v nix >/dev/null 2>&1 && echo "yes" || echo "no")"
  echo "mise: $(command -v mise >/dev/null 2>&1 && echo "yes ($(mise --version 2>/dev/null))" || echo "no")"
  echo ""
  echo "Legend:"
  echo "  ${GREEN}Nix only${NC}       = OK (managed by home-manager)"
  echo "  ${CYAN}mise only${NC}      = managed by mise (version manager)"
  echo "  ${YELLOW}system only${NC}    = installed via system package manager"
  echo "  ${YELLOW}homebrew only${NC}  = installed via Homebrew"
  echo "  ${YELLOW}manual only${NC}    = installed manually"
  echo "  ${RED}CONFLICT${NC}       = installed via multiple methods (remove non-Nix)"
  echo ""
  echo "Packages:"
  echo "────────────────────────────────────────────────────────────────"

  local conflicts=0
  local total=0

  for pkg_def in "${PACKAGES[@]}"; do
    IFS='|' read -r nix_name cmd sys_pkg <<< "$pkg_def"
    total=$((total + 1))
    if ! check_package "$nix_name" "$cmd" "$sys_pkg"; then
      conflicts=$((conflicts + 1))
    fi
  done

  echo "────────────────────────────────────────────────────────────────"
  echo ""
  echo "Summary: $total packages checked, $conflicts conflicts found"

  if [ $conflicts -gt 0 ]; then
    echo ""
    echo "${RED}Conflicts detected!${NC} Remove non-Nix installations to avoid conflicts."
    echo "Run this script again after uninstalling to verify."
    exit 1
  else
    echo ""
    echo "${GREEN}No conflicts!${NC} All packages are cleanly managed."
    exit 0
  fi
}

main "$@"
