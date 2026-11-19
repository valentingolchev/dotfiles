# foot terminal: package + config. Linux-only (Wayland); foot is nix-installed
# so gated on platform, not binary presence.
{ config, pkgs, lib, ... }:

lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
  home.packages = [ pkgs.foot ];

  xdg.configFile."foot/foot.ini".source = ./config/foot/foot.ini;

  # plain binary name: session PATH (systemd.user.sessionVariables in
  # home.nix) includes ~/.nix-profile/bin, so TryExec/Exec resolve there
  xdg.dataFile."applications/foot.desktop".text = ''
    [Desktop Entry]
    Name=Foot
    Comment=Fast, lightweight and minimalistic Wayland terminal emulator
    TryExec=foot
    Exec=foot
    Icon=foot
    Type=Application
    Categories=System;TerminalEmulator;
    Keywords=terminal;shell;prompt;command;commandline;
    StartupNotify=true
    StartupWMClass=foot
    Actions=NewWindow;

    [Desktop Action NewWindow]
    Name=New Window
    Exec=foot
  '';
}
