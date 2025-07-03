#!/bin/zsh
#
# Execution order
# 🚀 .zshenv
# -- .zprofile
# -- .zshrc

export LANG=en_US.UTF-8
export PATH="$PATH:/usr/local/opt/curl/bin"
export VISUAL=vim
export EDITOR="$VISUAL"

# Config Paths
export ZSH_CONFIG_PATH="$HOME/.config/zsh"
export ZSH_ALIASES_CONFIG_PATH="$HOME/.config/zsh/aliases"
export ZSH_WORK_CONFIG_PATH="$HOME/.config/zsh/work"
export ZSH_PLUGINS_PATH="$HOME/.config/zsh/plugins"

export TMUX_CONFIG_PATH="$HOME/.config/tmux"

# OS specific config setup
source "$ZSH_CONFIG_PATH/helper_fns.sh"
# loaded from helper_fns.sh
set_machine_env
if [[ $(is_macos) == true ]]; then
  export IS_MACOS=true
  export IS_LINUX=false
  export ZSH_OS_CONFIG_PATH="$HOME/.config/zsh/macos"
else
  export IS_MACOS=false
  export IS_LINUX=true
  export ZSH_OS_CONFIG_PATH="$HOME/.config/zsh/linux"
fi

#########################################################
#                                                       #
#                         XDG                           #
#                                                       #
#########################################################

XDG_CONFIG_HOME=$HOME/.config
XDG_DATA_HOME=$HOME/.local/share
XDG_STATE_HOME=$HOME/.local/state
XDG_CACHE_HOME=$HOME/.cache

#########################################################
#                                                       #
#                         RUST                          #
#                                                       #
#########################################################
[[ -s "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"

#########################################################
#                                                       #
#                       Aliases                         #
#                                                       #
#########################################################

alias srczsh='source ~/.zshrc'
alias srczprofile='source ~/.zprofile'
alias srczenv='source ~/.zshenv'

alias edit-dotfiles='cd ~/git/dotfiles && nvim .'
alias edit-dotfiles-work='cd ~/git/dotfiles-work && nvim .'

alias lse='eza --icons=always --group-directories-first -w=1'
alias ll='lse -l'
alias lla='lse -l -a'
alias cd='z'
alias ..='cd ..'

alias nv='nvim'

[[ $IS_LINUX == true ]] && alias wezterm='flatpak run org.wezfurlong.wezterm'

[[ -s "$ZSH_ALIASES_CONFIG_PATH/git.zsh" ]] && source "$ZSH_ALIASES_CONFIG_PATH/git.zsh"

[[ -s "$ZSH_OS_CONFIG_PATH/.zshenv" ]] && source "$ZSH_OS_CONFIG_PATH/.zshenv"
[[ -s "$ZSH_WORK_CONFIG_PATH/.zshenv" ]] && source "$ZSH_WORK_CONFIG_PATH/.zshenv"
