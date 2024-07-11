# Load work profile if it exists
[[ -s "$HOME/.zprofile.work" ]] && source "$HOME/.zprofile.work"

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

[[ -s "$HOME/.config/.aliases-git" ]] && source "$HOME/.config/.aliases-git"
[[ -s "$HOME/.config/.aliases-js" ]] && source "$HOME/.config/.aliases-js"

