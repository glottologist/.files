{ config, lib, pkgs, stdenv, ... }:
{
  programs = {
   rofi = {
    enable = true;
    terminal = "${pkgs.kitty}/bin/kitty";
    theme = ./themes/rectangle-everforest.rasi;
    };
  };
}
