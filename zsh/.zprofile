#!/bin/zsh
#
# Execution order
# ✅ .zshenv
# 🚀 .zprofile
# -- .zshrc

if [[ $(uname -m) == 'arm64' ]]; then
  export IS_ARM=true
  # echo "🚀 Running on ARM64"
else
  export IS_ARM=false
  # echo "🚀 Running on Intel"
fi

function try_load_brew() {
  local brew_path="${1}/bin/brew";
  if [ -f "$brew_path" ]; then
    # echo "✅ Homebrew setup successfully"
    eval "$($brew_path shellenv)"
  else
    echo "❌ Homebrew setup failed"
    # Debugging: list what is actually in $1/bin to see if brew is there
    echo "Contents of $brew_path:"
    ls -la "$brew_path"
  fi
}

function try_setup_ruby() {
  local ruby_path="$1";
  if [ -d "$ruby_path/opt/ruby/bin" ]; then
    # echo "✅ Using non-system Ruby"
    export PATH=$PATH:$ruby_path/opt/ruby/bin
    export PATH=$PATH:`gem environment gemdir`/bin
  else
    echo "❌ Using system Ruby"
  fi
}

if [[ $IS_ARM == true ]]; then
  try_load_brew "/opt/homebrew"
  try_setup_ruby "/opt/homebrew"
else
  try_load_brew "/usr/local"
  try_setup_ruby "/usr/local"
fi

[[ -s "$HOME/.config/.fzf.zsh" ]] && source "$HOME/.config/.fzf.zsh"

# Load work profile if it exists
[[ -s "$HOME/.work.zprofile" ]] && source "$HOME/.work.zprofile"
