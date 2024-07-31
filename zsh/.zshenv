#!/bin/zsh
#
# Execution order
# 🚀 .zshenv
# -- .zprofile
# -- .zshrc

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

