{ config, lib, pkgs, stdenv, ... }:
{

  imports = [
  ];

  home.packages = with pkgs; [
    anki              # Spaced repitition flashcards
    exercism          # A Go based command line tool for exercism.io
    gtypist           # Universal typing tutorial
    typespeed         # A curses based typing game
    ttyper            # Terminal-based typing test
    toipe             # Trusty terminal typing tester
    tuxtype           # An educational typing tutor game starring Tmux
    gotypist          # A touch-typing tutor
  ];

  programs = {
  };

  services = {
  };
}
