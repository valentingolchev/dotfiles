#!/bin/zsh
#
# Execution order
# ✅ .zshenv
# ✅ .zprofile
# 🚀 .zshrc
# 🚀 .config/zsh/macos/.zshrc

# Setup zsh-autosuggestions
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Setup zsh-syntax-highlighting
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
