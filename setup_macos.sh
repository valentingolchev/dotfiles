#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/scripts/setup_common.sh"

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew is required. Install it first: https://brew.sh" >&2
  exit 1
fi

if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
  print_common_help
  exit 0
fi

load_presets
parse_common_args "$@"

if $USE_TUI && ! command -v whiptail >/dev/null 2>&1; then
  echo "whiptail not found. Falling back to CLI selection." >&2
  USE_TUI=false
fi

SELECTED_DIRS_STR="$(choose_dirs)"
if [ -z "$SELECTED_DIRS_STR" ]; then
  echo "No selections made. Skipping setup."
  exit 0
fi

read -r -a SELECTED_DIRS <<< "$SELECTED_DIRS_STR"

PACKAGES=(git stow)

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
      ;;
    fastfetch)
      add_packages fastfetch
      ;;
    fonts)
      add_packages font-hack-nerd-font font-fira-mono-nerd-font font-jetbrains-mono-nerd-font
      ;;
    fzf)
      add_packages fzf
      ;;
    kitty)
      add_packages kitty
      ;;
    nvim)
      add_packages neovim
      ;;
    ripgrep)
      add_packages ripgrep
      ;;
    zsh)
      add_packages zsh zoxide eza fd starship
      ;;
    hyperland)
      echo "Skipping hyprland packages on macOS." >&2
      ;;
  esac
  done

log "Selected dirs: $SELECTED_DIRS_STR"
log "Packages: ${PACKAGES[*]}"

brew tap homebrew/cask
brew install "${PACKAGES[@]}"

if $DRY_RUN; then
  "$SCRIPT_DIR/symlink_all.sh" --dry-run --verbose "$VERBOSE" --dirs "$SELECTED_DIRS_STR"
else
  "$SCRIPT_DIR/symlink_all.sh" --verbose "$VERBOSE" --dirs "$SELECTED_DIRS_STR"
fi
