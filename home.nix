{ config, pkgs, lib, username, ... }:

{
  # Home Manager needs a username and home directory
  home.username = username;
  home.homeDirectory = if pkgs.stdenv.hostPlatform.isDarwin then "/Users/${username}" else "/home/${username}";

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
    direnv

    # Editor
    neovim
    tree-sitter # CLI required by nvim-treesitter to build parsers (erlang/elixir/zsh)

    # Terminal
    kitty

    # Theming
    tinty

    # Version manager
    mise

    # Kubernetes
    k9s

    # Diagram rendering (nvim mermaid via mmdc)
    mermaid-cli
    chromium # mmdc/puppeteer browser (path via PUPPETEER_EXECUTABLE_PATH below)
  ]
  # Linux-specific packages
  ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
    darkman
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

  ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
    # Nerd Fonts
    nerd-fonts.hack
    nerd-fonts.fira-mono
    nerd-fonts.jetbrains-mono

    # macOS tools
    ruby
  ];

  # Darkman: dark/light scheduler on Linux only (drives tinty directly via
  # dark-mode.d/light-mode.d/50-theme hooks + GTK/Qt via XDG portal).
  # macOS: launchd agent theme-sync-macos polls appearance -> tinty + foot signal.
  # geoclue needed for sunrise/sunset: NixOS system config
  # services.geoclue2.enable = true; other distros: distro geoclue2 package.
  # Fallback: usegeoclue = false + lat/lng. Manual toggle: darkmanctl toggle.
  xdg.configFile = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    "darkman/config.ini".text = ''
      [General]
      usegeoclue = true
      portal = true
      dbusserver = true
    '';
  };

  xdg.dataFile = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    "dark-mode.d/50-theme" = {
      text = ''
        #!/bin/sh
        # dark scheme: base16-kanagawa-dragon (change slugs here + light hook + theme-sync-macos)
        tinty apply base16-kanagawa-dragon
        pkill -USR1 -x foot 2>/dev/null || true
      '';
      executable = true;
    };
    "light-mode.d/50-theme" = {
      text = ''
        #!/bin/sh
        # light scheme: base16-kanagawa
        tinty apply base16-kanagawa
        pkill -USR2 -x foot 2>/dev/null || true
      '';
      executable = true;
    };
  };

  launchd.agents = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    theme-sync = {
      enable = true;
      config = {
        Label = "com.valgo.theme-sync";
        ProgramArguments = [ "/bin/sh" "-c" "$HOME/.local/bin/theme-sync-macos" ];
        EnvironmentVariables = {
          PATH = ''$HOME/.nix-profile/bin:$HOME/.local/bin:/usr/bin:/bin:/usr/sbin:/sbin'';
        };
        StartInterval = 60;
        RunAtLoad = true;
      };
    };
  };

  systemd.user.services.darkman = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    Unit = {
      Description = "Darkman dark/light scheduler";
    };
    Service = {
      ExecStart = "${pkgs.darkman}/bin/darkman run";
      Environment = "PATH=%h/.nix-profile/bin:%h/.local/bin:/usr/bin:/bin";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

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

  # Note: Program configs (bat, fzf, zoxide, eza, direnv) are managed by stow
  # in their respective dotfile directories. Do NOT add programs.* configs
  # here that would conflict with stow-managed files.

  # Home Manager state version (update when upgrading home-manager)
  home.stateVersion = "25.05";
}
