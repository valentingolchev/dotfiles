#!/bin/zsh
#
# Execution order
# ✅ .zshenv
# 🚀 .zprofile
# -- .zshrc

[[ -s "$HOME/.config/.fzf.zsh" ]] && source "$HOME/.config/.fzf.zsh"

[[ -s "$ZSH_OS_CONFIG_PATH/.zprofile" ]] && source "$ZSH_OS_CONFIG_PATH/.zprofile"
[[ -s "$ZSH_WORK_CONFIG_PATH/.zprofile" ]] && source "$ZSH_WORK_CONFIG_PATH/.zprofile"
# :NOTE Deprecated
[[ -s "$HOME/.work.zprofile" ]] && source "$HOME/.work.zprofile"
