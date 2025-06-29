#!/bin/zsh
#
# Execution order
# 🚀 .zshenv
# 🚀 .config/zsh/macos/.zshenv
# -- .zprofile
# -- .zshrc

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
