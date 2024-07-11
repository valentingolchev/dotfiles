# Load custom profile
[[ -s "$HOME/.zprofile.alias" ]] && source "$HOME/.zprofile.alias"
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

