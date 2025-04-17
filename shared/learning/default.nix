{ config, lib, pkgs, stdenv, ... }:
let
  #emanote = import (builtins.fetchTarball "https://github.com/srid/emanote/archive/master.tar.gz");
in {

  #imports = [ emanote.homeManagerModule ];

  home.packages = with pkgs; [
    #toipe             # Trusty terminal typing tester
    anki              # Spaced repitition flashcards
    bookworm          # A simple, focused eBook reader
    epr               # CLI Epub reader
    exercism          # A Go based command line tool for exercism.io
    gotypist          # A touch-typing tutor
    gtypist           # Universal typing tutorial
    koreader          # An ebook reader application supporting PDF, DjVu, EPUB, FB2 and many more formats, running on Cervantes, Kindle, Kobo, PocketBook and Android devices
    sigil             # Free, open source, multi-platform ebook (ePub) editor
    ttyper            # Terminal-based typing test
    # tuxtype           # An educational typing tutor game starring Tmux
    typespeed         # A curses based typing game
  ];

  programs = {
  };

  services = {
    #emanote = {
      #enable = true;
      ## host = "127.0.0.1"; # default listen address is 127.0.0.1
      ## port = 7000;        # default http port is 7000
      #notes = [
        #"/home/jason/Documents/languages"  # add as many layers as you like
        #"/home/jason/Documents/knowledge"  # add as many layers as you like
        #"/home/jason/Documents/notes"  # add as many layers as you like
      #];
      #package = emanote.packages.${builtins.currentSystem}.default;
    #};
  };
}
