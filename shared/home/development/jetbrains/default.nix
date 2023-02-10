{ config, lib, pkgs, ... }:
{
  home.packages = with pkgs; [

    jetbrains.webstorm
    jetbrains.idea-community
    jetbrains.pycharm-community
    jetbrains.goland
    jetbrains.datagrip
  ];
}
