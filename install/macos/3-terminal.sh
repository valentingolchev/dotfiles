#!/bin/sh

brew tap 'homebrew/cask'

brew install \
	git ruby bat stow ripgrep \
	fzf fd eza zoxide starship fastfetch \
	font-hack-nerd-font font-fira-mono-nerd-font font-jetbrains-mono-nerd-font \
	neovim tmux mise

brew install --cask wezterm

