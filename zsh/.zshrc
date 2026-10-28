#!/bin/zsh
#
# Execution order
# ✅ .zshenv
# ✅ .zprofile
# 🚀 .zshrc

# Fix zsh completions for Nix-installed zsh
if command -v zsh >/dev/null 2>&1; then
  ZSH_DIR=$(dirname $(dirname $(readlink -f $(which zsh))))
  fpath=($ZSH_DIR/share/zsh/site-functions $fpath)
  fpath=($ZSH_DIR/share/zsh/*/functions $fpath)

  # Set compdump location
  export ZSH_COMPDUMP=$HOME/.zcompdump

  # Run compinit, ignore errors if it fails
  autoload -Uz compinit && compinit 2>/dev/null || true
fi

# Setup ZSH plugins
source $ZSH_PLUGINS_PATH/zsh-autosuggestions/zsh-autosuggestions.zsh
source $ZSH_PLUGINS_PATH/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# setup NVM
export NVM_DIR="$HOME/.nvm"
[ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && . "/usr/local/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# setup history
HISTFILE=$HOME/.zhistory
SAVEHIST=1000
HISTSIZE=999
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify
bindkey "^[[A" history-search-backward
bindkey "^[[B" history-search-forward

# Set up fzf key bindings and fuzzy completion
[[ -x "$(command -v fzf)" ]] && eval "$(fzf --zsh)"
[[ -x "$(command -v zoxide)" ]] && eval "$(zoxide init zsh)"
# mise: only activate if mise is in PATH and working
if command -v mise >/dev/null 2>&1 && mise --version >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

[[ -s "$ZSH_OS_CONFIG_PATH/.zshrc" ]] && source "$ZSH_OS_CONFIG_PATH/.zshrc"
[[ -s "$ZSH_WORK_CONFIG_PATH/.zshrc" ]] && source "$ZSH_WORK_CONFIG_PATH/.zshrc"

[[ -s "$ZSH_CONFIG_PATH/prompt.zsh" ]] && source "$ZSH_CONFIG_PATH/prompt.zsh"

# opencode
export PATH=/home/valgo/.opencode/bin:$PATH

. "$HOME/.local/share/../bin/env"
