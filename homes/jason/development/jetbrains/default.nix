{ config, lib, pkgs, ... }:
{
  home.packages = with pkgs; [

    jetbrains.idea-community
    #jetbrains.datagrip
    #jetbrains.goland
    jetbrains.pycharm-community
    #jetbrains.webstorm
  ];
}
