# All Hyprland-specific packages, config files and logic live here.
# Applied only when a hyprland binary exists on the machine (this flake is
# evaluated with --impure, so builtins.pathExists is allowed).
{ config, pkgs, lib, ... }:

let
  hyprlandInstalled =
    builtins.pathExists "/usr/bin/hyprland"
    || builtins.pathExists "/usr/local/bin/hyprland"
    || builtins.pathExists "/run/current-system/sw/bin/hyprland"
    || builtins.pathExists "${config.home.homeDirectory}/.nix-profile/bin/hyprland";
in
lib.mkIf hyprlandInstalled {
  home.packages = with pkgs; [
    hyprland
    waybar
    wofi
    mako
  ];

  xdg.configFile."hypr/hyprland.conf".source = ./config/hypr/hyprland.conf;
}
