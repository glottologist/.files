{
  config,
  lib,
  pkgs,
  stdenv,
  ...
}: let
  host = "127.0.0.1";
  port = 1234;
  location = lib.strings.removeSuffix "\n" (builtins.readFile ../../../secrets/location.txt);
in {
  home.packages = with pkgs; [
  ];
  programs = {
  };
  services.glance = {
    enable = true;
    settings = {
      theme = {
         light = lib.mkForce "true";
        background-color = lib.mkForce "220 23 95"; # Latte base
  contrast-multiplier = lib.mkForce "1.0";
        primary-color = lib.mkForce "220 91 54"; # Latte blue
        positive-color = lib.mkForce "109 58 40"; # Latte green
        negative-color = lib.mkForce "347 87 44"; # Latte red

      };
      pages = [
        {
          name = "Start";
          width = "slim";
          hide-desktop-navigation = false;
          center-vertically = true;
          columns = [
            {
              size = "small";
              widgets = [
                {
                  type = "repository";
                  repository = "Irys-xyz/irys";
                  pull-requests-limit = 20;
                  issues-limit = 10;
                  commits-limit = 5;
                }
              ];
            }
            {
              size = "full";
              widgets = [
                {
                  type = "search";
                  autofocus = true;
                  search-engine = "google";
                  new-tab = true;
                  bangs = [
                    {
                      title = "YouTube";
                      shortcut = "!yt";
                      url = "https://www.youtube.com/results?search_query={QUERY}";
                    }
                    {
                      title = "Github";
                      shortcut = "!gh";
                      url = "https://github.com/search?q={QUERY}&type=repositories";
                    }
                  ];
                }
              ];
            }
          ];
        }
        {
          name = "Home";
          columns = [
            {
              size = "small";
              widgets = [
                {
                  type = "calendar";
                  first-day-of-week = "monday";
                }
                {
                  type = "rss";
                  limit = 10;
                  collapse-after = 3;
                  cache = "12h";
                  feeds = [
                    {
                      url = "https://blog.japaric.io/index.xml";
                      title = "Embedded Rust";
                      limit = 4;
                    }
                  ];
                }
              ];
            }
            {
              size = "full";
              widgets = [
                {
                  type = "group";
                  widgets = [
                    {type = "hacker-news";}
                    {type = "lobsters";}
                  ];
                }
                {
                  type = "videos";
                  channels = [
                    "UCXuqSBlHAE6Xw-yeJA0Tunw" # Linus Tech Tips
                    "UCR-DXc1voovS8nhAvccRZhg" # Jeff Geerling
                  ];
                }
                {
                  type = "group";
                  widgets = [
                    {
                      type = "reddit";
                      subreddit = "technology";
                      show-thumbnails = true;
                    }
                    {
                      type = "reddit";
                      subreddit = "selfhosted";
                      show-thumbnails = true;
                    }
                  ];
                }
              ];
            }
            {
              size = "small";
              widgets = [
                {
                  type = "weather";
                  location = "London, Europe";
                  units = "imperial";
                  hour-format = "12h";
                }
                {
                  type = "markets";
                  symbol-link-template = "https://www.tradingview.com/symbols/{SYMBOL}/news";
                  markets = [
                    {
                      symbol = "UKX";
                      name = "FTSE 100";
                    }
                    {
                      symbol = "LUK2";
                      name = "FTSE 100 Long 2x";
                    }
                    {
                      symbol = "SUK2";
                      name = "FTSE 100 Short 2x";
                    }
                    {
                      symbol = "3UKL";
                      name = "FTSE 100 Long 3x";
                    }
                    {
                      symbol = "3UKS";
                      name = "FTSE 100 Short 3x";
                    }
                    {
                      symbol = "BTCUSD";
                      name = "Bitcoin (USD)";
                    }
                    {
                      symbol = "ETHUSD";
                      name = "Ethereum (USD)";
                    }
                    {
                      symbol = "SOLUSD";
                      name = "Solana (USD)";
                    }
                    {
                      symbol = "NILUSD";
                      name = "Nillio";
                    }
                  ];
                }
                {
                  type = "releases";
                  cache = "1d";
                  repositories = [
                    "glottologist/seedmixer"
                    "glottologist/wisecrow"
                    "glottologist/towl"
                  ];
                }
              ];
            }
          ];
        }
      ];
      server = {inherit host port;};
    };
  };
}
