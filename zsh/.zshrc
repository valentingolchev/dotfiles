#!/bin/zsh
#
# Execution order
# ✅ .zshenv
# ✅ .zprofile
# 🚀 .zshrc

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
eval "$(fzf --zsh)"
eval "$(zoxide init zsh)"

[[ -s "$ZSH_OS_CONFIG_PATH/.zshrc" ]] && source "$ZSH_OS_CONFIG_PATH/.zshrc"
[[ -s "$ZSH_WORK_CONFIG_PATH/.zshrc" ]] && source "$ZSH_WORK_CONFIG_PATH/.zshrc"

[[ -s "$ZSH_CONFIG_PATH/prompt" ]] && source "$ZSH_CONFIG_PATH/prompt"
