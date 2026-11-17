{ config, pkgs, lib, username, ... }:

{
  imports = [
    ./modules/hyprland.nix
    ./modules/kitty.nix
    ./modules/foot.nix
    ./modules/theming.nix
    ./modules/darkman.nix
    ./modules/zsh.nix
  ];

  # Home Manager needs a username and home directory
  home.username = username;
  home.homeDirectory = if pkgs.stdenv.hostPlatform.isDarwin then "/Users/${username}" else "/home/${username}";

  # Disable release check warning
  home.enableNixpkgsReleaseCheck = false;

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  # Nix configuration — home-manager writes ~/.config/nix/nix.conf from these.
  # NOTE: substituters / trusted-public-keys / auto-optimise-store are restricted
  # settings: for untrusted users nix ignores them with a warning. To make them
  # effective, add the user to trusted-users in the SYSTEM /etc/nix/nix.conf
  # (NixOS: nix.settings.trusted-users = [ "@wheel" ] or your user).
  nix = {
    enable = true;
    package = pkgs.nix;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      warn-dirty = false;
      flake-registry = "${pkgs.nix}/share/nix/flake-registry.json";
      substituters = [
        "https://nix-community.cachix.org"
        "https://cache.nixos.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
    };
    gc = {
      automatic = false;  # Disabled to avoid conflicts with manual/system GC
    };
  };

  # Git configuration (new home-manager API: settings.*)
  programs.git = {
    enable = true;
    settings = {
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

    # Editor — nightly build via neovim-nightly-overlay (flake.nix)
    neovim
    tree-sitter # CLI required by nvim-treesitter to build parsers (erlang/elixir/zsh)

    # Version manager
    mise

    # Nerd Fonts (Linux + macOS)
    nerd-fonts.hack
    nerd-fonts.fira-mono
    nerd-fonts.jetbrains-mono

    # Kubernetes
    k9s

    # Diagram rendering (nvim mermaid via mmdc)
    mermaid-cli
    chromium # mmdc/puppeteer browser (path via PUPPETEER_EXECUTABLE_PATH below)

    # Password managers
    enpass        # unfree (allowUnfree in flake.nix), local vault ~/Documents/Enpass
    proton-pass   # free, GPL, syncs via Proton account
  ]
  # Linux-specific packages
  ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
    # Wayland tools
    wl-clipboard

    # System monitoring
    btop

    # Containers
    docker
    lazydocker
    podman-tui

    # Documentation
    tldr
    whois
  ]

  ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
    # macOS tools
    ruby

    #containers
  ];

  # Fontconfig picks up ~/.nix-profile fonts on Linux
  fonts.fontconfig.enable = pkgs.stdenv.hostPlatform.isLinux;

  # dotted-attr form (attrset-literal + // mkIf gets dropped by the module merge)
  xdg.configFile."bat/config".source = ./files/.config/bat/config;
  xdg.configFile."btop/btop.conf".source = ./files/.config/btop/btop.conf;
  xdg.configFile."eza/theme.yaml".source = ./files/.config/eza/theme.yaml;
  xdg.configFile."fastfetch/config.jsonc".source = ./files/.config/fastfetch/config.jsonc;
  xdg.configFile."k9s/config.yml".source = ./files/.config/k9s/config.yml;
  xdg.configFile."yazi/theme.toml".source = ./files/.config/yazi/theme.toml;
  xdg.configFile."yazi/flavors/everforest-light/theme.toml".source = ./files/.config/yazi/flavors/everforest-light/theme.toml;
  xdg.configFile."yazi/flavors/everforest-dark/theme.toml".source = ./files/.config/yazi/flavors/everforest-dark/theme.toml;
  xdg.configFile.".fzf.zsh".source = ./files/.config/.fzf.zsh;

  # Session variables
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    # mmdc/mermaid rendering: puppeteer resolves this per device (no hardcoded path in dotfiles)
    PUPPETEER_EXECUTABLE_PATH = "${pkgs.chromium}/bin/chromium";
  };

  # Session PATH
  home.sessionPath = [
    "$HOME/.nix-profile/bin"
    "$HOME/.local/bin"
    "$HOME/.cargo/bin"
    "$HOME/go/bin"
  ];

  # Program configs (migrated from stow to home-manager)
  # Sources live in files/ which mirrors $HOME (files/.config/... -> ~/.config/...).
  # nvim/claude/opencode still stow-managed.
  home.file.".ideavimrc".source = ./files/.ideavimrc;
  home.file.".rgignore".source = ./files/.rgignore;
  home.file."pdf-to-text.sh" = {
    source = ./files/pdf-to-text.sh;
    executable = true;
  };
  # Home Manager state version (update when upgrading home-manager)
  home.stateVersion = "25.05";
}
