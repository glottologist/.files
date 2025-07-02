{
  config,
  lib,
  pkgs,
  stdenv,
  ...
}: {
  imports = [
    ./fastfetch/default.nix
    ./fish/default.nix
    ./foot/default.nix
    ./kitty/default.nix
    ./ghostty/default.nix
    ./starship/default.nix
    ./tmux/default.nix
  ];

  home.packages = with pkgs; [
    atac #A simple API client (postman like) in your terminal
    eza # Command line file tree
    flameshot # Powerfull yet simple to use screenshot software
    grc # Colourizer
    hushboard # Mute your microphone while typing
    ncdu # Terminal space explorer
    ranger # Curses like file explorer
    ripgrep #  Utility to that combines the usability of the silver searcher with the raw speed of grep
    rofi-screenshot # Use rofi to perform various types of screenshots and screen captures
    shellclear # Find sensitive data in your shell
    shell-gpt # Access ChatGPT from your terminal
    shotman # The uncompromising screenshot GUI for Wayland compositors
    termdown # Command line timer
    tldr # Community driven manpages
    tmate # Instant terminal sharing
    wayshot # A native, blazing-fast screenshot tool for wlroots based compositors such as sway and river
  ];

  programs = {
    atuin = {
      enable = true;
      enableFishIntegration = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };
    aria2.enable = true; # aria2 is a lightweight multi-protocol & multi-source command-line download utility.
    bat = {
      enable = true;
      config = {
        pager = "less -FR";
      };
      extraPackages = with pkgs.bat-extras; [
        batman
        batpipe
        batgrep
      ];
    };
    broot = {
      # Easy way to see and navigate directory trees in Linux
      enable = true;
      enableFishIntegration = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };
    btop = {
      enable = true;
      settings = {
        vim_keys = true;
      };
    };
    cava = {
      enable = true;
      settings = {
        general = {
          bar_spacing = 1;
          bar_width = 2;
        };
        color = {
          gradient = 1;
          gradient_color_1 = "'#011f30'";
          gradient_color_2 = "'#09465b'";
          gradient_color_3 = "'#045a93'";
          gradient_color_4 = "'#00aa00'";
          gradient_color_5 = "'#ffff00'";
          gradient_color_6 = "'#cc8033'";
          gradient_color_7 = "'#aa0000'";
          gradient_color_8 = "'#ff00ff'";
          # Old config
          #gradient = 1;
          #gradient_color_1 = "'#8bd5ca'";
          #gradient_color_2 = "'#91d7e3'";
          #gradient_color_3 = "'#7dc4e4'";
          #gradient_color_4 = "'#8aadf4'";
          #gradient_color_5 = "'#c6a0f6'";
          #gradient_color_6 = "'#f5bde6'";
          #gradient_color_7 = "'#ee99a0'";
          #gradient_color_8 = "'#ed8796'";
          # Dracula
          #gradient_color_1 = '#8BE9FD'
          #gradient_color_2 = '#9AEDFE'
          #gradient_color_3 = '#CAA9FA'
          #gradient_color_4 = '#BD93F9'
          #gradient_color_5 = '#FF92D0'
          #gradient_color_6 = '#FF79C6'
          #gradient_color_7 = '#FF6E67'
          #gradient_color_8 = '#FF5555'
        };
      };
    };
    direnv = {
      # Utility to load and unload environment variables depending on the current directory.
      enable = true;
      nix-direnv = {
        enable = true;
      };
    };
    eza = {
      enable = true;
      enableFishIntegration = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
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
      enableFishIntegration = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      options = [
        "--cmd cd"
      ];
    };
  };
}
