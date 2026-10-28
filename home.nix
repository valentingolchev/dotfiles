{ config, pkgs, lib, username, ... }:

{
  # Home Manager needs a username and home directory
  home.username = username;
  home.homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  # Packages managed by home-manager (replaces setup_linux.sh / setup_macos.sh package installation)
  home.packages = with pkgs; [
    # Base tools (always needed)
    git
    stow

    # Core CLI tools
    bat
    eza
    yazi
    fd
    fzf
    ripgrep
    zoxide
    fastfetch

    # Shell
    zsh

    # Editor
    neovim

    # Terminal
    kitty

    # Version manager
    mise
  ]
  # Linux-specific packages
  ++ lib.optionals pkgs.stdenv.isLinux [
    # Fonts
    fontconfig

    # Build tools (replaces Arch base-devel)
    gcc
    gnumake
    unzip

    # Wayland tools
    wl-clipboard
    foot

    # System monitoring
    btop

    # Documentation
    man-db
    tldr
    whois

    # Hyprland (if needed, uncomment)
    # hyprland
    # waybar
    # wofi
    # mako
  ]
  # macOS-specific packages
  ++ lib.optionals pkgs.stdenv.isDarwin [
    # Nerd Fonts
    nerd-fonts.hack
    nerd-fonts.fira-mono
    nerd-fonts.jetbrains-mono

    # macOS tools
    ruby
  ];

  # Session variables
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. Don't change this unless you know what you're doing.
  home.stateVersion = "24.05";
}
