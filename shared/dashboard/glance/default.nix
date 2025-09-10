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
        light = lib.mkForce true;
        background-color = lib.mkForce "220 23 95"; # Latte base
        contrast-multiplier = lib.mkForce 1.0;
        primary-color = lib.mkForce "220 91 54"; # Latte blue
        positive-color = lib.mkForce "109 58 40"; # Latte green
        negative-color = lib.mkForce "347 87 44"; # Latte red
      };
      pages = [
        {
          name = "Home";
          hide-desktop-navigation = false;
          center-vertically = true;
          columns = [
            {
              size = "small";
              widgets = [
                {
                  type = "calendar";
                  first-day-of-week = "monday";
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
            {
              size = "small";
              widgets = [
                {
                  type = "weather";
                  location = "${location}";
                  units = "metric";
                  hour-format = "24h";
                }
              ];
            }
          ];
        }
        {
          name = "Social";
          hide-desktop-navigation = false;
          center-vertically = true;
          columns = [
            {
              size = "small";
              widgets = [
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
          ];
        }
        {
          name = "Development";
          hide-desktop-navigation = false;
          center-vertically = true;
          columns = [
            {
              size = "full";
              widgets = [
                {
                  type = "repository";
                  repository = "glottologist/seedmixer";
                  pull-requests-limit = 5;
                  issues-limit = 5;
                  commits-limit = 5;
                }
                {
                  type = "repository";
                  repository = "glottologist/wisecrow";
                  pull-requests-limit = 5;
                  issues-limit = 5;
                  commits-limit = 5;
                }
                {
                  type = "repository";
                  repository = "glottologist/towl";
                  pull-requests-limit = 5;
                  issues-limit = 5;
                  commits-limit = 5;
                }
                {
                  type = "releases";
                  cache = "1d";
                  repositories = [
                    "glottologist/seedmixer"
                  ];
                }
              ];
            }
          ];
        }
        {
          name = "Irys";
          hide-desktop-navigation = false;
          center-vertically = true;
          columns = [
            {
              size = "full";
              widgets = [
                {
                  type = "repository";
                  repository = "Irys-xyz/irys";
                  pull-requests-limit = 20;
                  issues-limit = 10;
                  commits-limit = 10;
                }
              ];
            }
          ];
        }
        {
          name = "Finance";
          columns = [
            {
              size = "full";
              widgets = [
                {
                  type = "markets";
                  markets = [
                    {
                      symbol = "^FTSE";
                      name = "FTSE 100";
                    }
                  ];
                }
                {
                  type = "markets";
                  markets = [
                    {
                      symbol = "BTC";
                      name = "Bitcoin (USD)";
                    }
                    {
                      symbol = "ETH";
                      name = "Ethereum (USD)";
                    }
                    {
                      symbol = "SOL";
                      name = "Solana (USD)";
                    }
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
