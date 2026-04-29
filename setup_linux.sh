#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/scripts/setup_common.sh"

detect_linux_distro() {
  local distro_id=""

  if [ -r /etc/os-release ]; then
    distro_id="$(. /etc/os-release; printf '%s' "$ID")"
  fi

  case "$distro_id" in
    arch)
      echo "arch"
      ;;
    ubuntu)
      echo "ubuntu"
      ;;
    *)
      echo ""
      ;;
  esac
}

DISTRO="$(detect_linux_distro)"
case "$DISTRO" in
  arch)
    if command -v paru >/dev/null 2>&1; then
      PKG_MANAGER="paru"
      UPDATE=(paru -Syu --noconfirm)
      INSTALL=(paru -S --noconfirm)
    elif command -v pacman >/dev/null 2>&1; then
      PKG_MANAGER="pacman"
      UPDATE=(sudo pacman -Syu --noconfirm)
      INSTALL=(sudo pacman -S --noconfirm)
    else
      echo "Arch setup requires paru or pacman." >&2
      exit 1
    fi
    ;;
  ubuntu)
    if command -v apt-get >/dev/null 2>&1; then
      PKG_MANAGER="apt"
      UPDATE=(sudo apt-get update)
      INSTALL=(sudo apt-get install -y)
    else
      echo "Ubuntu setup requires apt-get." >&2
      exit 1
    fi
    ;;
  *)
    echo "Unsupported Linux distro. This setup currently supports Arch and Ubuntu only." >&2
    exit 1
    ;;
esac

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
  print_common_help
  exit 0
fi

load_presets
parse_common_args "$@"

if $USE_TUI && ! command -v whiptail >/dev/null 2>&1; then
  "${UPDATE[@]}"
  case "$PKG_MANAGER" in
    apt) "${INSTALL[@]}" whiptail ;;
    pacman|paru) "${INSTALL[@]}" libnewt ;;
  esac
fi

log "Linux distro: $DISTRO"
log "Package manager: $PKG_MANAGER"

SELECTED_DIRS_STR="$(choose_dirs)"
if [ -z "$SELECTED_DIRS_STR" ]; then
  echo "No selections made. Skipping setup."
  exit 0
fi

read -r -a SELECTED_DIRS <<< "$SELECTED_DIRS_STR"

FD_PKG="fd"
if [ "$DISTRO" = "ubuntu" ]; then
  FD_PKG="fd-find"
fi

PACKAGES=(git stow)
STOW_DIRS=()

add_packages() {
  local pkg
  for pkg in "$@"; do
    if [ -n "$pkg" ] && [[ ! " ${PACKAGES[*]} " =~ " ${pkg} " ]]; then
      PACKAGES+=("$pkg")
    fi
  done
}

for dir in "${SELECTED_DIRS[@]}"; do
  case "$dir" in
    bat)
      add_packages bat
      STOW_DIRS+=("$dir")
      ;;
    fastfetch)
      add_packages fastfetch
      STOW_DIRS+=("$dir")
      ;;
    fonts)
      add_packages fontconfig
      STOW_DIRS+=("$dir")
      ;;
    fzf)
      add_packages fzf
      STOW_DIRS+=("$dir")
      ;;
    hyperland)
      if command -v hyprland >/dev/null 2>&1; then
        STOW_DIRS+=("$dir")
      else
        log "Hyprland not installed; skipping hyprland stow."
      fi
      ;;
    kitty)
      add_packages kitty
      STOW_DIRS+=("$dir")
      ;;
    nvim)
      add_packages neovim
      if [ "$DISTRO" = "arch" ]; then
        add_packages base-devel unzip
      fi
      STOW_DIRS+=("$dir")
      ;;
    ripgrep)
      add_packages ripgrep
      STOW_DIRS+=("$dir")
      ;;
    zsh)
      add_packages zsh zoxide eza "$FD_PKG" starship mise
      STOW_DIRS+=("$dir")
      ;;
  esac
  done

SELECTED_DIRS_STR="${STOW_DIRS[*]}"
if [ -z "$SELECTED_DIRS_STR" ]; then
  echo "No stowable selections remain. Skipping setup."
  exit 0
fi

log "Selected dirs: $SELECTED_DIRS_STR"
log "Packages: ${PACKAGES[*]}"

"${UPDATE[@]}"
"${INSTALL[@]}" "${PACKAGES[@]}"

if $DRY_RUN; then
  "$SCRIPT_DIR/symlink_all.sh" --dry-run --verbose "$VERBOSE" --dirs "$SELECTED_DIRS_STR"
else
  "$SCRIPT_DIR/symlink_all.sh" --verbose "$VERBOSE" --dirs "$SELECTED_DIRS_STR"
fi
