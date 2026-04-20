#!/bin/bash
set -e

COMMON_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$COMMON_DIR/.." && pwd)"

DOTFILES_DIRS=(bat fastfetch fonts fzf hyperland idea kitty nvim ripgrep zsh)
DEFAULT_DOTFILES_DIRS=(bat fastfetch fonts fzf idea kitty nvim ripgrep zsh)

DEFAULT_SELECT_ALL=true
USE_TUI=true
DRY_RUN=false
PRESELECT_DIRS=""
VERBOSE=false

PRESET_REPO="$DOTFILES_ROOT/.setup-preset"
PRESET_USER="$HOME/.config/dotfiles/setup-preset"

print_common_help() {
  cat <<'EOF'
Options:
  --dry-run       Show what would be stowed
  --no-tui        Use CLI prompts instead of a TUI
  --select-none   Start with no selections
  --dirs "..."    Space-separated list of dotfile directories
  --verbose       Print extra setup details

Preset files (optional, same options):
  .setup-preset (repo)
  ~/.config/dotfiles/setup-preset
EOF
}

log() {
  if $VERBOSE; then
    echo "$@"
  fi
}

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  echo "$value"
}

parse_bool() {
  case "$(echo "$1" | tr '[:upper:]' '[:lower:]')" in
    true|1|yes|on) echo true ;;
    false|0|no|off) echo false ;;
    *) echo "" ;;
  esac
}

apply_preset_key() {
  local key="$1"
  local value="$2"
  local bool_value

  case "$key" in
    dirs)
      PRESELECT_DIRS="$value"
      ;;
    tui)
      bool_value="$(parse_bool "$value")"
      if [ -n "$bool_value" ]; then
        USE_TUI=$bool_value
      fi
      ;;
    select_none)
      bool_value="$(parse_bool "$value")"
      if [ -n "$bool_value" ]; then
        if $bool_value; then
          DEFAULT_SELECT_ALL=false
        else
          DEFAULT_SELECT_ALL=true
        fi
      fi
      ;;
    dry_run)
      bool_value="$(parse_bool "$value")"
      if [ -n "$bool_value" ]; then
        DRY_RUN=$bool_value
      fi
      ;;
    verbose)
      bool_value="$(parse_bool "$value")"
      if [ -n "$bool_value" ]; then
        VERBOSE=$bool_value
      fi
      ;;
  esac
}

load_preset_file() {
  local preset_file="$1"
  [ -f "$preset_file" ] || return 0

  while IFS= read -r line || [ -n "$line" ]; do
    local trimmed
    trimmed="$(trim "$line")"
    [ -z "$trimmed" ] && continue
    case "$trimmed" in
      \#*)
        continue
        ;;
    esac

    if [[ "$trimmed" == *"="* ]]; then
      local key="${trimmed%%=*}"
      local value="${trimmed#*=}"
      key="$(trim "$key")"
      value="$(trim "$value")"
      apply_preset_key "$key" "$value"
    else
      PRESELECT_DIRS="$trimmed"
    fi
  done < "$preset_file"
}

load_presets() {
  load_preset_file "$PRESET_REPO"
  load_preset_file "$PRESET_USER"
}

parse_common_args() {
  while [ $# -gt 0 ]; do
    case "$1" in
      --dry-run)
        DRY_RUN=true
        ;;
      --no-tui)
        USE_TUI=false
        ;;
      --select-none)
        DEFAULT_SELECT_ALL=false
        ;;
      --dirs)
        shift
        PRESELECT_DIRS="$1"
        ;;
      --verbose)
        VERBOSE=true
        ;;
      --help|-h)
        print_common_help
        exit 0
        ;;
      *)
        echo "Unknown option: $1" >&2
        exit 1
        ;;
    esac
    shift
  done
}

describe_dir() {
  case "$1" in
    bat) echo "bat pager" ;;
    fastfetch) echo "fastfetch greeting" ;;
    fonts) echo "fonts config" ;;
    fzf) echo "fzf fuzzy finder" ;;
    hyperland) echo "hyprland config" ;;
    idea) echo "idea settings" ;;
    kitty) echo "kitty terminal" ;;
    nvim) echo "neovim config" ;;
    ripgrep) echo "ripgrep config" ;;
    zsh) echo "zsh shell" ;;
    *) echo "dotfiles" ;;
  esac
}

choose_dirs() {
  if [ -n "$PRESELECT_DIRS" ]; then
    echo "$PRESELECT_DIRS"
    return 0
  fi

  if $USE_TUI && command -v whiptail >/dev/null 2>&1; then
    local options=()
    local state
    for dir in "${DOTFILES_DIRS[@]}"; do
      if $DEFAULT_SELECT_ALL; then
        state="OFF"
        if [[ " ${DEFAULT_DOTFILES_DIRS[*]} " =~ " ${dir} " ]]; then
          state="ON"
        fi
      else
        state="OFF"
      fi
      options+=("$dir" "$(describe_dir "$dir")" "$state")
    done

    local result
    result=$(whiptail --title "Dotfiles setup" --checklist "Select dotfile groups to setup" 20 78 12 "${options[@]}" 3>&1 1>&2 2>&3) || exit 1
    echo "$result" | tr -d '"'
    return 0
  fi

  echo "Available dotfile groups:"
  for dir in "${DOTFILES_DIRS[@]}"; do
    printf "  %-12s %s\n" "$dir" "$(describe_dir "$dir")"
  done

  if $DEFAULT_SELECT_ALL; then
    echo "Press Enter to select all."
  else
    echo "Press Enter to select none."
  fi
  printf "Enter space-separated selections: "
  read -r input
  if [ -z "$input" ]; then
    if $DEFAULT_SELECT_ALL; then
      echo "${DEFAULT_DOTFILES_DIRS[*]}"
    else
      echo ""
    fi
  else
    echo "$input"
  fi
}

stow_dirs() {
  local stow_args=("-t" "$HOME")
  if $DRY_RUN; then
    stow_args=("-n" "-t" "$HOME")
  fi

  for dir in "$@"; do
    if [ -d "$dir" ]; then
      stow "${stow_args[@]}" "$dir"
    fi
  done
}
