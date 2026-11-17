# All kitty-specific package + config live here (unconditional: kitty is
# installed by nix, so no binary-presence gate like hyprland).
{ pkgs, ... }:

{
  home.packages = [ pkgs.kitty ];

  xdg.configFile = {
    "kitty/kitty.conf".source = ../files/.config/kitty/kitty.conf;
    "kitty/keybinds.conf".source = ../files/.config/kitty/keybinds.conf;
    "kitty/kittens/get_layout.py".source = ../files/.config/kitty/kittens/get_layout.py;
    "kitty/kittens/pass_keys.py".source = ../files/.config/kitty/kittens/pass_keys.py;
    "kitty/kittens/test.json".source = ../files/.config/kitty/kittens/test.json;
    "kitty/kittens/url_select.py" = {
      source = ../files/.config/kitty/kittens/url_select.py;
      executable = true;
    };
    # per-OS kitty listen socket (listen-channel.conf wins over kitty.conf)
    "kitty/listen-channel.conf".text =
      if pkgs.stdenv.hostPlatform.isDarwin
      then "listen_on unix:/tmp/mykitty\n"
      else "listen_on unix:@mykitty\n";
  };
}
