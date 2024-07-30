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

#########################################################
#                                                       #
#                       Aliases                         #
#                                                       #
#########################################################

alias srczsh='source ~/.zshrc'
alias srczprofile='source ~/.zprofile'
alias srczenv='source ~/.zshenv'

alias edit-dotfiles='nvim ~/git/dotfiles'
alias edit-dotfiles-work='nvim ~/git/dotfiles-work'

alias lse='eza --icons=always --group-directories-first -w=1'
alias ll='lse -l'
alias lla='lse -l -a'
alias cd='z'
alias ..='cd ..'

alias nv='nvim'

alias reset_dock="~/.config/reset_macos_dock.sh"

[[ -s "$HOME/.config/.aliases-git" ]] && source "$HOME/.config/.aliases-git"
[[ -s "$HOME/.config/.fzf.zsh" ]] && source "$HOME/.config/.fzf.zsh"

# Load work profile if it exists
[[ -s "$HOME/.work.zprofile" ]] && source "$HOME/.work.zprofile"
