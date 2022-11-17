{ config, lib, pkgs, stdenv, ... }:
let
  emanote = import (builtins.fetchTarball "https://github.com/srid/emanote/archive/master.tar.gz");
in {

  imports = [ emanote.homeManagerModule ];

  home.packages = with pkgs; [
    anki              # Spaced repitition flashcards
    exercism          # A Go based command line tool for exercism.io
    gtypist           # Universal typing tutorial
    typespeed         # A curses based typing game
    ttyper            # Terminal-based typing test
    #toipe             # Trusty terminal typing tester
    tuxtype           # An educational typing tutor game starring Tmux
    gotypist          # A touch-typing tutor
  ];

  programs = {
  };

  services = {
    emanote = {
      enable = true;
      # host = "127.0.0.1"; # default listen address is 127.0.0.1
      # port = 7000;        # default http port is 7000
      notes = [
        "/home/jason/Documents/languages"  # add as many layers as you like
        "/home/jason/Documents/knowledge"  # add as many layers as you like
        "/home/jason/Documents/notes"  # add as many layers as you like
      ];
      package = emanote.packages.${builtins.currentSystem}.default;
    };
  };
}
