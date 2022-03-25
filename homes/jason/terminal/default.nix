{ config, lib, pkgs, stdenv, ... }:
{

  imports = [
    ./tmux/default.nix
    ./alacritty/default.nix
    ./fish/default.nix
    ./starship/default.nix
    ./rofi/default.nix
  ];

  home.packages = with pkgs; [
    tmate
  ];


  programs = {
    aria2.enable = true;  # aria2 is a lightweight multi-protocol & multi-source command-line download utility.
    bat.enable = true;   # Drop in replacement for cat
    broot = {   # Easy way to see and navigate directory trees in Linux
      enable = true;
      #enableFishIntegration = true;
    };
    direnv = {   # Utility to load and unload environment variables depending on the current directory.
      enable = true;
      nix-direnv = {
        enable = true;
      };
    };
    fzf = {  # A command line fuzzy finder
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
    lsd.enable = true;  # Next gen 'ls' command
    mcfly.enable = true; #  McFly replaces your default ctrl-r shell history search with an intelligent search engine that takes into account your working directory and the context of recently executed commands.
    newsboat = {  # Terminal RSS/Atom
      enable = true;
      urls = (map (x: {url = x; tags = ["maintaining"];}) [
                   "https://discourse.nixos.org/latest.rss"
                   "https://cointelegraph.com/feed"
                   "https://www.coindesk.com/feed"
                   "https://medium.com/feed/blockchain-blog"
                   "https://blog.bitfinex.com/feed/"
                   "https://blog.trezor.io/feed"
	           ]) ;
		  reloadTime = 5;
    };
   pet.enable = true;  # A command line snippet manager
   zoxide = { # A better CD command
      enable = true;
      options = [];
   };
  };
}
