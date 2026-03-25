{
  config,
  lib,
  pkgs,
  stdenv,
  ...
}: let
in {
  home.packages = with pkgs; [
    toipe
    anki
    calibre # Comprehensive e-book management
    epr # CLI Epub reader
    foliate # GTK4-based e-book reader
    gotypist # A touch-typing tutor
    gtypist # Universal typing tutorial
    koreader # An ebook reader application supporting PDF, DjVu, EPUB, FB2 and many more formats, running on Cervantes, Kindle, Kobo, PocketBook and Android devices
    readest # Cross-platform e-book reader with cloud sync
    sigil # Free, open source, multi-platform ebook (ePub) editor
    ttyper # Terminal-based typing test
    tuxtype # An educational typing tutor game starring Tmux
    typespeed # A curses based typing game
    obsidian # Powerful knowledge base that works on top of a local folder of plain text Markdown files
    googleearth-pro # Globe viewer
  ];

  programs = {
  };

  services = {
  };
}
