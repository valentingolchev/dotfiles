# foot terminal: package + config. Linux-only (Wayland); foot is nix-installed
# so gated on platform, not binary presence.
{ pkgs, lib, ... }:

lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
  home.packages = [ pkgs.foot ];

  xdg.configFile."foot/foot.ini".source = ../files/.config/foot/foot.ini;

  xdg.dataFile."applications/foot.desktop".source = ../files/.local/share/applications/foot.desktop;
}
