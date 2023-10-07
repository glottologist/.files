{ config, lib, pkgs, stdenv, ... }:
{
  programs = {
   rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    terminal = "${pkgs.kitty}/bin/kitty";
    theme = ./themes/catppuccin-latte.rasi;
    };
  };
}
