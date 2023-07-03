{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    cascadia-code
    fira
    fira-code
    fira-mono
    fira-code-symbols
    font-awesome
    nerdfix
    nerd-font-patcher
    (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
  ];
}
