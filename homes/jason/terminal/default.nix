{ config, lib, pkgs, stdenv, ... }:
{

  imports = [
    ./tmux/tmux.nix
    ./alacritty/default.nix
  ];

  home.packages = with pkgs; [
    tmate
  ];
}
