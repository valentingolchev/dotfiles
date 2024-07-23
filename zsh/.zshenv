#!/bin/zsh
#
# Execution order
# 🚀 .zshenv
# -- .zprofile
# -- .zshrc

export PATH="$PATH:/usr/local/opt/curl/bin"

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

