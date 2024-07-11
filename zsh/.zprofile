# Don't use MacOS system Ruby

if [ -d "/opt/homebrew/opt/ruby/bin" ]; then
  export PATH=/opt/homebrew/opt/ruby/bin:$PATH
  export PATH=`gem environment gemdir`/bin:$PATH
fi

if [ -d "/usr/local/opt/ruby/bin" ]; then
  export PATH=/usr/local/opt/ruby/bin:$PATH
  export PATH=`gem environment gemdir`/bin:$PATH
fi

#########################################################
#                                                       #
#                       Aliases                         #
#                                                       #
#########################################################

alias srczsh='source ~/.zshrc'
alias srczprofile='source ~/.zprofile'
alias srczenv='source ~/.zenv'

alias ls="eza --icons=always"
alias ll="ls -l"
alias lla="ls -la"
alias cd="z"

[[ -s "$HOME/.config/.aliases-git" ]] && source "$HOME/.config/.aliases-git"

# Load work profile if it exists
[[ -s "$HOME/.zprofile.work" ]] && source "$HOME/.zprofile.work"

