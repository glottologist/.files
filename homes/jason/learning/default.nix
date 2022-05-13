{ config, lib, pkgs, stdenv, ... }:
{

  imports = [
  ];

  home.packages = with pkgs; [
    anki              # Spaced repitition flashcards
  ];

  programs = {
  };

  services = {
  };
}
