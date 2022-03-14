{ config, lib, pkgs, stdenv, ... }:
{

  imports = [
    ./git/default.nix
    ./neovim/default.nix
    #./vscode/default.nix
    #./jetbrains/default.nix
  ];

  home.packages = with pkgs; [
  ];


  programs = {
  };

  services = {
    lorri.enable = true;

  };
}
