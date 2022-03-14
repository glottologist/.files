{ config, lib, pkgs, stdenv, ... }:
{

  imports = [
    ./git/default.nix
  ];

  home.packages = with pkgs; [
  ];


  programs = {
  };

  services = {
    lorri.enable = true;

  };
}
