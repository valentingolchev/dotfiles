#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/scripts/setup_common.sh"

load_presets
parse_common_args "$@"

SELECTED_DIRS_STR="$(choose_dirs)"
if [ -z "$SELECTED_DIRS_STR" ]; then
  echo "No selections made. Skipping symlink step."
  exit 0
fi

log "Selected dirs: $SELECTED_DIRS_STR"

if $DRY_RUN; then
  "$SCRIPT_DIR/symlink_all.sh" --dry-run --verbose "$VERBOSE" --dirs "$SELECTED_DIRS_STR"
else
  "$SCRIPT_DIR/symlink_all.sh" --verbose "$VERBOSE" --dirs "$SELECTED_DIRS_STR"
fi
