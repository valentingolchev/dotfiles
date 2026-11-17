# Theming: tinty + macOS launchd theme-sync + theme hook scripts.
# darkman (Linux scheduler) lives in modules/darkman.nix.
{ pkgs, lib, ... }:

{
  home.packages = [ pkgs.tinty ];

  xdg.configFile."tinted-theming/tinty/config.toml".source = ../files/.config/tinted-theming/tinty/config.toml;

  # macOS: launchd agent polls appearance -> tinty + foot signal
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

  home.file.".local/bin/theme-defaults" = {
    source = ../files/.local/bin/theme-defaults;
    executable = true;
  };
  home.file.".local/bin/theme-hook" = {
    source = ../files/.local/bin/theme-hook;
    executable = true;
  };
  home.file.".local/bin/theme-sync-macos" = {
    source = ../files/.local/bin/theme-sync-macos;
    executable = true;
  };
}
