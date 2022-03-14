{  pkgs, ... }:
{
  xdg.configFile."alacritty/alacritty.yml".source = ./alacritty.yml;
  programs.alacritty = {
    enable = true;
    settings = {
      shell.program = "${pkgs.fish}/bin/fish";
    };
  };
}
