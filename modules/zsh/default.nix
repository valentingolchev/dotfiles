# zsh shell: package, direnv, config files, plugins (from nixpkgs).
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    zsh
    direnv
  ];

  xdg.configFile."zsh/aliases.zsh".source = ./config/zsh/aliases.zsh;
  xdg.configFile."zsh/helper_fns.sh".source = ./config/zsh/helper_fns.sh;
  xdg.configFile."zsh/prompt.zsh".source = ./config/zsh/prompt.zsh;
  xdg.configFile."zsh/linux/.zshenv".source = ./config/zsh/linux/.zshenv;
  xdg.configFile."zsh/macos/.zshenv".source = ./config/zsh/macos/.zshenv;
  xdg.configFile."zsh/macos/.zshrc".source = ./config/zsh/macos/.zshrc;
  xdg.configFile."zsh/macos/reset_macos_dock.sh" = {
    source = ./config/zsh/macos/reset_macos_dock.sh;
    executable = true;
  };
  # plugins from nixpkgs (not vendored); nixpkgs puts them under
  # $out/share/zsh/plugins/<name>/, so link that subdir as the plugin dir
  xdg.configFile."zsh/plugins/zsh-autosuggestions".source = "${pkgs.zsh-autosuggestions}/share/zsh/plugins/zsh-autosuggestions";
  # zsh-syntax-highlighting installs to $out/share/zsh-syntax-highlighting (not share/zsh/plugins/...)
  xdg.configFile."zsh/plugins/zsh-syntax-highlighting".source = "${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting";

  home.file.".zshrc".source = ./home/.zshrc;
  home.file.".zshenv".source = ./home/.zshenv;
  home.file.".zprofile".source = ./home/.zprofile;
}
