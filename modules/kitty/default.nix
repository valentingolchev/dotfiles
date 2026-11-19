# All kitty-specific package + config live here (unconditional: kitty is
# installed by nix, so no binary-presence gate like hyprland).
{ config, pkgs, ... }:

{
  # nix kitty dlopens libEGL/libwayland from the system, but nix glibc never
  # searches /lib64 (nix-ld env vars did not take effect for kitty's dlopen).
  # Wrap with LD_LIBRARY_PATH=/lib64; kitty.conf scrubs it for child processes
  # (system zsh chokes on it otherwise).
  home.packages = [
    (pkgs.symlinkJoin {
      name = "kitty";
      paths = [ pkgs.kitty ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/kitty --set LD_LIBRARY_PATH /lib64
      '';
    })
  ];

  xdg.configFile = {
    "kitty/kitty.conf".source = ./config/kitty/kitty.conf;
    "kitty/keybinds.conf".source = ./config/kitty/keybinds.conf;
    "kitty/kittens/get_layout.py".source = ./config/kitty/kittens/get_layout.py;
    "kitty/kittens/pass_keys.py".source = ./config/kitty/kittens/pass_keys.py;
    "kitty/kittens/test.json".source = ./config/kitty/kittens/test.json;
    "kitty/kittens/url_select.py" = {
      source = ./config/kitty/kittens/url_select.py;
      executable = true;
    };
    "kitty/kittens/swap_window.py".source = ./config/kitty/kittens/swap_window.py;
    "kitty/kittens/launch_dev_session.py".source = ./config/kitty/kittens/launch_dev_session.py;
    "kitty/sessions/dev.kitty-session".source = ./config/kitty/sessions/dev.kitty-session;
    # per-OS kitty listen socket (listen-channel.conf wins over kitty.conf)
    "kitty/listen-channel.conf".text =
      if pkgs.stdenv.hostPlatform.isDarwin
      then "listen_on unix:/tmp/mykitty\n"
      else "listen_on unix:@mykitty\n";
  };

  # desktop entries: main terminal app + NoDisplay URL/mime launcher
  # plain binary names: session PATH (systemd.user.sessionVariables in
  # home.nix) includes ~/.local/bin, so TryExec/Exec resolve there
  xdg.dataFile = {
    "applications/kitty.desktop".text = ''
      [Desktop Entry]
      Version=1.0
      Type=Application
      Name=kitty
      GenericName=Terminal emulator
      Comment=Fast, feature-rich, GPU based terminal
      TryExec=kitty
      Exec=kitty
      Icon=kitty
      Categories=System;TerminalEmulator;
      StartupNotify=true
      X-TerminalArgExec=--
      X-TerminalArgTitle=--title
      X-TerminalArgAppId=--class
      X-TerminalArgDir=--working-directory
      X-TerminalArgHold=--hold
    '';
    "applications/kitty-open.desktop".text = ''
      [Desktop Entry]
      Version=1.0
      Type=Application
      Name=kitty URL Launcher
      GenericName=Terminal emulator
      Comment=Open URLs with kitty
      StartupNotify=true
      TryExec=kitty
      Exec=kitty +open %U
      Icon=kitty
      Categories=System;TerminalEmulator;
      NoDisplay=true
      MimeType=image/*;application/x-sh;application/x-shellscript;inode/directory;text/*;x-scheme-handler/kitty;x-scheme-handler/ssh;
    '';
  };
}
