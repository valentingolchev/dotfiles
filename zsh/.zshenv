export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

export PATH=$PATH:/Applications/Genymotion.app/Contents/MacOS/tools
export PATH="/usr/local/opt/curl/bin:$PATH"

#########################################################
#                                                       #
#                       Fastlane                        #
#                                                       #
#########################################################
# export FASTLANE_HOME=/usr/local/bin/fastlane
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export GEM_HOME=~/.gems
export ANDROID_HOME=/Users/valentingolchev/Library/Android/sdk
export PATH=$HOME/bin:$GEM_HOME:/usr/local/bin:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$PATH
export PATH="$HOME/.fastlane/bin:$PATH"

#########################################################
#                                                       #
#                       Oh My Zsh                       #
#                                                       #
#########################################################
export ZSH="$HOME/.oh-my-zsh"

#########################################################
#                                                       #
#                         EXPO                          #
#                                                       #
#########################################################
export EXPO_USERNAME="dunkvalio"
export EXPO_PASSWORD="Giddily-voucher9-chitchat"
export SENTRY_EXPO_AUTH_TOKEN="7110f398fcd94beeb45045068f8042d9417490de1b594ff49bbe72b37148ce12"

export EB_FACEBOOK_DISPLAY_NAME="live_easyreservation"
export EB_FACEBOOK_SCHEME="fb172057156800272"
export EB_FACEBOOK_APP_ID="172057156800272"

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

# default to Java 11
java11

#########################################################
#                                                       #
#                       Aliases                         #
#                                                       #
#########################################################

alias srcbrc='source ~/.bashrc'
alias srcprofile='source ~/.bash_profile'
alias srczshrc='source ~/.zshrc'
alias cd-eba='cd ~/workspace/easybook-admin-mobile'
alias cd-ebc='cd ~/workspace/easybook-mobile-client'

#############################################
#                                           #
#             Project Setup                 #
#                                           #
#############################################

alias setup-eslint="export PKG=eslint-config-airbnb; npm info '$PKG@latest' peerDependencies --json | command sed 's/[\{\},]//g ; s/: /@/g' | xargs npm install --save-dev '$PKG@latest'"

#############################################
#                                           #
#              Git Commands                 #
#                                           #
#############################################
alias gs='git status'
alias st='status'
alias ga='git add'
alias gb='git branch'
alias gc='git commit'
alias gd='git diff'
alias go='git checkout'
alias co='checkout'
alias gk='gitk --all&'
alias gx='gitx --all'
alias g='git'
alias got='git'
alias get='git'
alias fetch='git fetch'
alias pull='git pull'
alias push='git push'
alias upload='git push -u origin'
alias clean='git clean -df'
alias up='push origin'
alias down='pull origin'
alias br='checkout -b'
alias publish='git push -u origin $(git branch --show-current)'
alias unpublish='git push origin :$(git branch --show-current)'

alias ghist='g log --pretty --graph --date=short'
alias gbclean='git branch --merged | grep -v "\*" | xargs -n 1 git branch -d'

#############################################
#                                           #
#                React Native               #
#                                           #
#############################################

alias rn='react-native'
alias rn-ra='react-native run-android'
alias rn-loga='react-native log-android'
alias rn-pkgr='react-native start --port 8081'
alias packager-eb='cd-eb && react-native start --port 8081'
alias run-eb='cd-eb && react-native run-android'
alias log-eb='cd-eb && react-native log-android'

#############################################
#                                           #
#                    NPM                    #
#                                           #
#############################################

alias ls-global-pkgs='npm list -g --depth=0'
alias npm-pkgs='npm list --depth=0'
alias yarn-pkgs='yarn list --depth=0'

