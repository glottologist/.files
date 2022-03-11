{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
     dive  # A tool to analyse docker image layers
  ];
}
