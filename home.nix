{ config, pkgs, lib, username, ... }:

{
  # Home Manager needs a username and home directory
  home.username = username;
  home.homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";

  # Disable release check warning
  home.enableNixpkgsReleaseCheck = false;

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  # Nix configuration
  nix = {
    enable = true;
    package = pkgs.nix;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      warn-dirty = false;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  # Git configuration
  programs.git = {
    enable = true;
    userName = "valgo";
    userEmail = "valgo@example.com";  # TODO: update with your email
    aliases = {
      co = "checkout";
      br = "branch";
      st = "status";
      ci = "commit";
      unstage = "restore --staged";
      last = "log -1 HEAD";
      visual = "!gitk";
    };
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      core.editor = "nvim";
    };
  };

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
    starship
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

  # Home Manager state version (update when upgrading home-manager)
  home.stateVersion = "25.05";
}
