#!/bin/sh
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OS="$(uname -s)"

print_help() {
  cat <<'EOF'
Usage: ./setup.sh [options]

Runs the OS-specific setup script.

Options are forwarded to the OS setup script. Common options:
  --dry-run       Show what would be installed and stowed
  --no-tui        Use CLI prompts instead of a TUI
  --select-none   Start with no selections
  --dirs "..."    Space-separated list of dotfile directories
  --verbose       Print extra setup details
  --help, -h      Show this help text

Preset files (optional, same options):
  .setup-preset (repo)
  ~/.config/dotfiles/setup-preset
EOF
}

case "$OS" in
  Darwin)
    if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
      print_help
      exit 0
    fi
    "$SCRIPT_DIR/setup_macos.sh" "$@"
    ;;
  Linux)
    if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
      print_help
      exit 0
    fi
    "$SCRIPT_DIR/setup_linux.sh" "$@"
    ;;
  *)
    if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
      print_help
      exit 0
    fi
    echo "Unsupported OS: $OS" >&2
    exit 1
    ;;
esac
