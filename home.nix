{ config, pkgs, lib, username, ... }:

{
  # Home Manager needs a username and home directory
  home.username = username;
  home.homeDirectory = if pkgs.stdenv.hostPlatform.isDarwin then "/Users/${username}" else "/home/${username}";

  # Disable release check warning
  home.enableNixpkgsReleaseCheck = false;

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  # Nix configuration (managed by home-manager via nix.* options)
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

    # Editor — nightly build via neovim-nightly-overlay (flake.nix)
    neovim
    tree-sitter # CLI required by nvim-treesitter to build parsers (erlang/elixir/zsh)

    # Terminal
    kitty

    # Theming
    tinty

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
    darkman
    # Wayland tools
    wl-clipboard
    foot

    # System monitoring
    btop

    # Containers
    docker
    lazydocker
    podman-tui

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
    # macOS tools
    ruby

    #containers
  ];

  # Fontconfig picks up ~/.nix-profile fonts on Linux
  fonts.fontconfig.enable = pkgs.stdenv.hostPlatform.isLinux;

  # Darkman: dark/light scheduler on Linux only (drives tinty directly via
  # dark-mode.d/light-mode.d/50-theme hooks + GTK/Qt via XDG portal).
  # macOS: launchd agent theme-sync-macos polls appearance -> tinty + foot signal.
  # geoclue needed for sunrise/sunset: NixOS system config
  # services.geoclue2.enable = true; other distros: distro geoclue2 package.
  # Fallback: usegeoclue = false + lat/lng. Manual toggle: darkmanctl toggle.
  xdg.configFile = {
    "bat/config".source = ./files/.config/bat/config;
    "btop/btop.conf".source = ./files/.config/btop/btop.conf;
    "eza/theme.yaml".source = ./files/.config/eza/theme.yaml;
    "fastfetch/config.jsonc".source = ./files/.config/fastfetch/config.jsonc;
    "k9s/config.yml".source = ./files/.config/k9s/config.yml;
    "yazi/theme.toml".source = ./files/.config/yazi/theme.toml;
    "yazi/flavors/everforest-light/theme.toml".source = ./files/.config/yazi/flavors/everforest-light/theme.toml;
    "yazi/flavors/everforest-dark/theme.toml".source = ./files/.config/yazi/flavors/everforest-dark/theme.toml;
    "tinted-theming/tinty/config.toml".source = ./files/.config/tinted-theming/tinty/config.toml;
    ".fzf.zsh".source = ./files/.config/.fzf.zsh;
    "hypr/hyprland.conf".source = ./files/.config/hypr/hyprland.conf;
    "foot/foot.ini".source = ./files/.config/foot/foot.ini;
    "kitty/kitty.conf".source = ./files/.config/kitty/kitty.conf;
    "kitty/keybinds.conf".source = ./files/.config/kitty/keybinds.conf;
    "kitty/kittens/get_layout.py".source = ./files/.config/kitty/kittens/get_layout.py;
    "kitty/kittens/pass_keys.py".source = ./files/.config/kitty/kittens/pass_keys.py;
    "kitty/kittens/test.json".source = ./files/.config/kitty/kittens/test.json;
    "kitty/kittens/url_select.py" = {
      source = ./files/.config/kitty/kittens/url_select.py;
      executable = true;
    };
  } // lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    "darkman/config.ini".text = ''
      [General]
      usegeoclue = true
      portal = true
      dbusserver = true
    '';
  };

  xdg.dataFile = {
    "applications/foot.desktop".source = ./files/.local/share/applications/foot.desktop;
  } // lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    "dark-mode.d/50-theme" = {
      text = ''
        #!/bin/sh
        # dark default: base16-kanagawa-dragon (override via theme-defaults wins at runtime)
        exec "$HOME/.local/bin/theme-hook" dark base16-kanagawa-dragon
      '';
      executable = true;
    };
    "light-mode.d/50-theme" = {
      text = ''
        #!/bin/sh
        # light default: base16-kanagawa (override via theme-defaults wins at runtime)
        exec "$HOME/.local/bin/theme-hook" light base16-kanagawa
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

  # Program configs (migrated from stow to home-manager)
  # Sources live in files/ which mirrors $HOME (files/.config/... -> ~/.config/...).
  # zsh/nvim/claude/opencode still stow-managed.
  home.file.".ideavimrc".source = ./files/.ideavimrc;
  home.file.".rgignore".source = ./files/.rgignore;
  home.file."pdf-to-text.sh" = {
    source = ./files/pdf-to-text.sh;
    executable = true;
  };
  home.file.".local/bin/theme-defaults" = {
    source = ./files/.local/bin/theme-defaults;
    executable = true;
  };
  home.file.".local/bin/theme-hook" = {
    source = ./files/.local/bin/theme-hook;
    executable = true;
  };
  home.file.".local/bin/theme-sync-macos" = {
    source = ./files/.local/bin/theme-sync-macos;
    executable = true;
  };

  # Home Manager state version (update when upgrading home-manager)
  home.stateVersion = "25.05";
}
