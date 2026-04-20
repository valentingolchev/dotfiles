#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DEFAULT_DIRS=(bat fastfetch fonts fzf hyperland idea kitty nvim ripgrep zsh)
DRY_RUN=false
VERBOSE=false
DIRS=()
BACKUP_ROOT="$HOME/.dotfiles-backup/$(date +%Y%m%d%H%M%S)"
BACKUP_CREATED=false

print_help() {
  cat <<'EOF'
Usage: symlink_all.sh [options]

Options:
  --dry-run       Show what would be stowed
  --dirs "..."    Space-separated list of dotfile directories
  --verbose       Print extra details
  --help          Show this help text

Conflicts are moved to:
  ~/.dotfiles-backup/<timestamp>
EOF
}

log() {
  if $VERBOSE; then
    echo "$@"
  fi
}

ensure_backup_root() {
  if ! $BACKUP_CREATED; then
    mkdir -p "$BACKUP_ROOT"
    BACKUP_CREATED=true
    log "Backup dir: $BACKUP_ROOT"
  fi
}

backup_conflicts() {
  local dir="$1"
  local conflicts

  conflicts=$(stow -n -t "$HOME" "$dir" 2>&1 | awk '/^\s*existing target/ { print $NF }')
  if [ -z "$conflicts" ]; then
    return 0
  fi

  ensure_backup_root

  while IFS= read -r target; do
    [ -z "$target" ] && continue
    if [ -e "$target" ] || [ -L "$target" ]; then
      local rel_path
      rel_path="${target#"$HOME"/}"
      mkdir -p "$BACKUP_ROOT/$(dirname "$rel_path")"
      mv "$target" "$BACKUP_ROOT/$rel_path"
      log "Backed up: $target"
    fi
  done <<< "$conflicts"
}

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run)
      DRY_RUN=true
      ;;
    --verbose)
      VERBOSE=true
      ;;
    --dirs)
      shift
      if [ -n "$1" ]; then
        read -r -a DIRS <<< "$1"
      fi
      ;;
    --help|-h)
      print_help
      exit 0
      ;;
    *)
      DIRS+=("$1")
      ;;
  esac
  shift
  done

if [ ${#DIRS[@]} -eq 0 ]; then
  DIRS=("${DEFAULT_DIRS[@]}")
fi

stow_args=("-t" "$HOME")
if $DRY_RUN; then
  stow_args=("-n" "-t" "$HOME")
fi

log "Stowing dirs: ${DIRS[*]}"
if $DRY_RUN; then
  log "Dry run enabled"
fi

cd "$SCRIPT_DIR"
for dir in "${DIRS[@]}"; do
  if [ -d "$dir" ]; then
    if ! $DRY_RUN; then
      backup_conflicts "$dir"
    fi
    stow "${stow_args[@]}" "$dir"
  fi
done
