# darkman: dark/light scheduler, Linux only. Kept in its own module because
# it uses attrset-literal definitions, which can't be mixed with dotted-attr
# entries in the same file.
{ pkgs, lib, ... }:

lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
  home.packages = [ pkgs.darkman ];

  # geoclue needed for sunrise/sunset: NixOS system config
  # services.geoclue2.enable = true; other distros: distro geoclue2 package.
  xdg.configFile = {
    "darkman/config.ini".text = ''
      [General]
      usegeoclue = true
      portal = true
      dbusserver = true
    '';
  };

  xdg.dataFile = {
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

  systemd.user.services.darkman = {
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
}
