export LANG=en_US.UTF-8

eval "$('/opt/homebrew/bin/brew' shellenv)"

#!/bin/zsh
#
# Execution order
# ✅ .zshenv
# ✅ .zprofile
# 🚀 .zshrc

# Setup zsh-autosuggestions
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Setup zsh-syntax-highlighting
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

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

export PATH="$PATH:$HOME/.tmux/plugins/tmuxifier/bin"
eval "$(tmuxifier init -)"

# Set up fzf key bindings and fuzzy completion
eval "$(fzf --zsh)"

eval "$(zoxide init zsh)"
eval "$(starship init zsh)"

[[ -s "$HOME/.work.zshrc" ]] && source "$HOME/.work.zshrc"

