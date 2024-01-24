{
  config,
  lib,
  pkgs,
  stdenv,
  ...
}: {
  imports = [
    ./alacritty/default.nix
    ./fish/default.nix
    ./foot/default.nix
    ./kitty/default.nix
    ./rofi/default.nix
    ./starship/default.nix
    ./tmux/default.nix
  ];

  home.packages = with pkgs; [
    #eza           # Command line file tree
    # ripgrep-all   # Ripgrep but search in pdfs, ebooks office docs etc. TODO:BROKEN
    flameshot # Powerfull yet simple to use screenshot software
    hushboard # Mute your microphone while typing
    ncdu # Terminal space explorer
    ripgrep #  Utility to that combines the usability of the silver searcher with the raw speed of grep
    rofi-screenshot # Use rofi to perform various types of screenshots and screen captures
    shotman # The uncompromising screenshot GUI for Wayland compositors
    termdown # Command line timer
    termius # Modern cross device SSH Terminal
    tmate # Instant terminal sharing
    wayshot # A native, blazing-fast screenshot tool for wlroots based compositors such as sway and river
  ];

  programs = {
    aria2.enable = true; # aria2 is a lightweight multi-protocol & multi-source command-line download utility.
    bat.enable = true; # Drop in replacement for cat
    broot = {
      # Easy way to see and navigate directory trees in Linux
      enable = true;
      #enableFishIntegration = true;
    };
    direnv = {
      # Utility to load and unload environment variables depending on the current directory.
      enable = true;
      nix-direnv = {
        enable = true;
      };
    };
    fzf = {
      # A command line fuzzy finder
      enable = true;
      #enableFishIntegration = true;
    };
    htop = {
      enable = true; # Command line system monitor
      settings = {
        sort_direction = true;
        sort_key = "PERCENT_CPU";
      };
    };
    jq.enable = true; # JSON processor
    lsd.enable = true; # Next gen 'ls' command
    #mcfly.enable = true; #  McFly replaces your default ctrl-r shell history search with an intelligent search engine that takes into account your working directory and the context of recently executed commands.
    newsboat = {
      # Terminal RSS/Atom
      enable = true;
      urls =
        map (x: {
          url = x;
          tags = ["maintaining"];
        }) [
          "https://discourse.nixos.org/latest.rss"
          "https://cointelegraph.com/feed"
          "https://www.coindesk.com/feed"
          "https://medium.com/feed/blockchain-blog"
          "https://blog.bitfinex.com/feed/"
          "https://blog.trezor.io/feed"
        ];
      reloadTime = 5;
    };
    pet.enable = true; # A command line snippet manager
    zoxide = {
      # A better CD command
      enable = true;
      options = [];
    };
  };
}
