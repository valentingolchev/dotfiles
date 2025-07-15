#!/bin/sh

sudo dnf install -y dnf-plugins-core
sudo dnf config-manager addrepo --from-repofile=https://mise.jdx.dev/rpm/mise.repo
sudo dnf install -y mise

sudo dnf install \
	fd eza fzf ripgrep zoxide bat \
	wl-clipboard fastfetch btop \
	man tldr whois

flatpak install flathub org.wezfurlong.wezterm

