#!/bin/zsh

export PATH="/usr/local/opt/curl/bin:$PATH"

#########################################################
#                                                       #
#                         JAVA                          #
#                                                       #
#########################################################
export JAVA_8_HOME=$(/usr/libexec/java_home -v1.8)
export JAVA_11_HOME=$(/usr/libexec/java_home -v11)
export JAVA_12_HOME=$(/usr/libexec/java_home -v12)

alias java8='export JAVA_HOME=$JAVA_8_HOME'
alias java11='export JAVA_HOME=$JAVA_11_HOME'
alias java12='export JAVA_HOME=$JAVA_12_HOME'

jdk() {
  version=$1
  export JAVA_HOME=$(/usr/libexec/java_home -v"$version");
  java -version
}

. "$HOME/.cargo/env"
