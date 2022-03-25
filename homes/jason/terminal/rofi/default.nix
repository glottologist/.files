{ config, lib, pkgs, stdenv, ... }:
{
  programs = {
   rofi = {
    enable = true;
    terminal = "${pkgs.alacritty}/bin/alacritty";
    theme = ./themes/nord-oneline.rasi;
    };
  };
}
