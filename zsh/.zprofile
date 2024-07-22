#!/bin/zsh

if [ -d "/opt/homebrew/bin/brew" ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if [ -d "/usr/local/bin/brew" ]; then
  eval "$(/usr/local/bin/brew shellenv)"
if

# Don't use MacOS system Ruby
if [ -d "/opt/homebrew/opt/ruby/bin" ]; then
  export PATH=/opt/homebrew/opt/ruby/bin:$PATH
  export PATH=`gem environment gemdir`/bin:$PATH
fi

if [ -d "/usr/local/opt/ruby/bin" ]; then
  export PATH=/usr/local/opt/ruby/bin:$PATH
  export PATH=`gem environment gemdir`/bin:$PATH
fi

export EDITOR='nvim'

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

alias ls="eza --icons=always --group-directories-first -w=1"
alias ll="ls -l"
alias lla='ls -l -a'
alias cd="z"
alias ..="cd .."

alias vi='nvim'
alias invim='nvim $(fzf -m --preview="bat --color=always {}")'

[[ -s "$HOME/.config/.aliases-git" ]] && source "$HOME/.config/.aliases-git"
[[ -s "$HOME/.config/.fzf.zsh" ]] && source "$HOME/.config/.fzf.zsh"

# Load work profile if it exists
[[ -s "$HOME/.work.zprofile" ]] && source "$HOME/.work.zprofile"

