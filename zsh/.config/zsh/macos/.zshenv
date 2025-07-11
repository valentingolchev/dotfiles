#!/bin/zsh
#
# Execution order
# 🚀 .zshenv
# 🚀 .config/zsh/macos/.zshenv
# -- .zprofile
# -- .zshrc

if [[ $(uname -m) == 'arm64' ]]; then
  export IS_ARM=true
else
  export IS_ARM=false
fi

function try_load_brew() {
  local brew_path="${1}/bin/brew";
  if [ -f "$brew_path" ]; then
    echo "✅ Homebrew setup successfully: ${1}"
    eval "$($brew_path shellenv)"

    export PATH=${1}/bin:$PATH
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

alias reset_dock="$(dirname "$0")/reset_macos_dock.sh"

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
