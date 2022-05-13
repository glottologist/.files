{ config, lib, pkgs, stdenv, ... }:
{

  imports = [
  ];

  home.packages = with pkgs; [
    anki              # Spaced repitition flashcards
    exercism          # A Go based command line tool for exercism.io
  ];

  programs = {
  };

  services = {
  };
}
