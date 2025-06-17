#!/bin/zsh
#
# Execution order
# 🚀 .zshenv
# -- .zprofile
# -- .zshrc

export LANG=en_US.UTF-8

export PATH="$PATH:/usr/local/opt/curl/bin"

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
#                         JAVA                          #
#                                                       #
#########################################################

jdk() {
  version=$1 # e.g 1.8, 11, 12, 17, 21
  export JAVA_HOME=$(/usr/libexec/java_home -v"$version");
  java -version
}

#########################################################
#                                                       #
#                         RUST                          #
#                                                       #
#########################################################
. "$HOME/.cargo/env"


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

alias reset_dock="~/.config/reset_macos_dock.sh"

[[ -s "$HOME/.config/.aliases-git" ]] && source "$HOME/.config/.aliases-git"

# Load work profile if it exists
[[ -s "$HOME/.work.zshenv" ]] && source "$HOME/.work.zshenv"
