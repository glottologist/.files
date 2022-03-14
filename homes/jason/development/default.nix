{ config, lib, pkgs, stdenv, ... }:
{

  imports = [
    ./git/default.nix
    ./vsliveshare/default.nix
  ];

  home.packages = with pkgs; [
  ];


  programs = {
  };

  services = {
    lorri.enable = true;

  };
}
