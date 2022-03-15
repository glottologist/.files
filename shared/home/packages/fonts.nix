{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
    cascadia-code
    fira-code
    fira-code-symbols
    fira-mono
    font-awesome
    nerdfonts
  ];
}
