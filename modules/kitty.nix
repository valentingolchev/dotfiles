# All kitty-specific package + config live here (unconditional: kitty is
# installed by nix, so no binary-presence gate like hyprland).
{ pkgs, ... }:

{
  home.packages = [ pkgs.kitty ];

  xdg.configFile = {
    "kitty/kitty.conf".source = ./kitty/kitty.conf;
    "kitty/keybinds.conf".source = ./kitty/keybinds.conf;
    "kitty/kittens/get_layout.py".source = ./kitty/kittens/get_layout.py;
    "kitty/kittens/pass_keys.py".source = ./kitty/kittens/pass_keys.py;
    "kitty/kittens/test.json".source = ./kitty/kittens/test.json;
    "kitty/kittens/url_select.py" = {
      source = ./kitty/kittens/url_select.py;
      executable = true;
    };
    # per-OS kitty listen socket (listen-channel.conf wins over kitty.conf)
    "kitty/listen-channel.conf".text =
      if pkgs.stdenv.hostPlatform.isDarwin
      then "listen_on unix:/tmp/mykitty\n"
      else "listen_on unix:@mykitty\n";
  };
}
