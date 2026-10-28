{ config, pkgs, lib, username, ... }:

{
  # Home Manager needs a username and home directory
  home.username = username;
  home.homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";

  # Disable release check warning
  home.enableNixpkgsReleaseCheck = false;

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  # Nix configuration (managed by home-manager, no home.file needed)
  nix = {
    enable = true;
    package = pkgs.nix;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      warn-dirty = false;
      flake-registry = "${pkgs.nix}/share/nix/flake-registry.json";
    };
    gc = {
      automatic = false;  # Disabled to avoid conflicts with manual/system GC
    };
  };

  # Git configuration (new home-manager API: settings.*)
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Valentin Golchev";
        email = "v.golchev@gmail.com";
      };
      alias = {
        co = "checkout";
        br = "branch";
        st = "status";
        ci = "commit";
        unstage = "restore --staged";
        last = "log -1 HEAD";
        visual = "!gitk";
      };
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
    # Wayland tools
    wl-clipboard
    foot

    # System monitoring
    btop

    # Documentation
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
  ];

  # Session variables
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # Session PATH
  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.cargo/bin"
    "$HOME/go/bin"
  ];

  # Note: Program configs (bat, fzf, zoxide, eza, direnv) are managed by stow
  # in their respective dotfile directories. Do NOT add programs.* configs
  # here that would conflict with stow-managed files.

  # Home Manager state version (update when upgrading home-manager)
  home.stateVersion = "25.05";
}
