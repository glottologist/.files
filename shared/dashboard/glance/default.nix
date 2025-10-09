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
                {
                  type = "clock";
                  hour-format = "24h";
                  timezones = [
                    {
                      timezone = "Europe/London";
                      label = "London";
                    }
                    {
                      timezone = "America/New_York";
                      label = "New York";
                    }
                    {
                      timezone = "America/Los_Angeles";
                      label = "Los Angeles";
                    }
                  ];
                }
              ];
            }
            {
              size = "full";
              widgets = [
                {
                  type = "search";
                  autofocus = true;
                  search-engine = "https://presearch.com/search?q={QUERY}";
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
                  show-area-name = true;
                }
                {
                  type = "to-do";
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
                  ];
                }
                {
                  type = "videos";
                  style = "grid-cards";
                  collapse-after-rows = 5;
                  channels = [
                    "UCnLxFpGiCi-u3RLx9uF8bOg" # Russell Howard
                    "UCjSEJkpGbcZhvo0lr-44X_w" # TechHut
                    "UCOzMAa6IhV6uwYQATYG_2kg" # Novara Media
                    "UCeFNDxd7NqmM6FkMQC-tgMw" # Kingsland Records
                    "UCXuqSBlHAE6Xw-yeJA0Tunw" # Linus Tech Tips
                    "UCR-DXc1voovS8nhAvccRZhg" # Jeff Geerling
                    "UCGq-a57w-aPwyi3pW7XLiHw" # Diary of a CEO
                    "UCsufaClk5if2RGqABb-09Uw" # The Rest Is Politics
                    "UCg3hvCXDzFq6ZwSNcmZ62YA" # The Rest Is Politics : Leading
                    "UC7IcJI8PUf5Z3zKxnZvTBog" # The School of Life
                    "UCLksRXfBiEITZMUo2ssjSdA" # Rust Nation
                    "UC9x0AN7BWHpCDHSm9NiJFJQ" # Network Chuck
                    "UCPmfPl-BsCd3wmE8i45LAoA" # Simon Sinek
                    "UC5Ghe5TBQGYIOANuiNW4hDQ" # Gary's Economics
                    "UCwWhs_6x42TyRM4Wstoq8HA" # The Daily Show
                    "UCYJpsKWYfZU8kOHZf_tUzQw" # The Rest Is Entertainment
                    "UCWiiMnsnw5Isc2PP1to9nNw" # Unchained
                    "UCUyeluBRhGPCW4rPe_UvBZQ" # The Primeagen
                    "UC_iD0xppBwwsrM9DegC5cQQ" # Jon Gjengset
                    "UCeRYN0tYBQVrC2cKsxJjdow" # Double Down News
                    "UCUBj_5pwQZaoXfBrEQQbADw" # Chase Hughes
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
                      subreddit = "Damnthatsinteresting";
                      show-thumbnails = true;
                    }
                    {
                      type = "reddit";
                      subreddit = "europe";
                      show-thumbnails = true;
                    }
                    {
                      type = "reddit";
                      subreddit = "mildlyinfuriating";
                      show-thumbnails = true;
                    }
                    {
                      type = "reddit";
                      subreddit = " interestingasfuck";
                      show-thumbnails = true;
                    }
                  ];
                }
              ];
            }
          ];
        }
        {
          name = "Glottologist";
          hide-desktop-navigation = false;
          center-vertically = true;
          columns = [
            {
              size = "small";
              widgets = [
                {
                  type = "releases";
                  cache = "1d";
                  repositories = [
                    "glottologist/seedmixer"
                  ];
                }
              ];
            }
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
              size = "small";
              widgets = [
                {
                  type = "markets";
                  title = "Fiat";
                  markets = [
                    {
                      symbol = "^FTSE";
                      name = "FTSE 100";
                    }
                  ];
                }
                {
                  type = "markets";
                  title = "Crypto";
                  markets = [
                    {
                      symbol = "BTC-USD";
                      name = "Bitcoin (USD)";
                      symbol-link = "https://www.tradingview.com/symbols/BTCUSD/news?exchange=COINBASE";
                      chart-link = "https://www.tradingview.com/symbols/BTCUSD/chart?exchange=COINBASE";
                    }
                    {
                      symbol = "ETH";
                      name = "Ethereum (USD)";
                      symbol-link = "https://www.tradingview.com/symbols/ETHUSD/news?exchange=COINBASE";
                      chart-link = "https://www.tradingview.com/symbols/ETHUSD/chart?exchange=COINBASE";
                    }
                    {
                      symbol = "SOL";
                      name = "Solana (USD)";
                      symbol-link = "https://www.tradingview.com/symbols/SOLUSD/news?exchange=COINBASE";
                      chart-link = "https://www.tradingview.com/symbols/SOLUSD/chart?exchange=COINBASE";
                    }
                  ];
                }
              ];
            }
            {
              size = "full";
              widgets = [
                {
                  type = "rss";
                  title = "Financial News";
                  style = "detailed-list";
                  limit = 20;
                  collapse-after = 10;
                  cache = "2h";
                  feeds = [
                    {
                      url = "https://feeds.bloomberg.com/markets/news.rss";
                      title = "Bloomberg";
                      limit = 10;
                    }
                    {
                      url = "https://www.ft.com/rss/home";
                      title = "FT";
                      limit = 10;
                    }
                    {
                      url = "https://seekingalpha.com/feed.xml";
                      title = "Seeking Alpha";
                      limit = 10;
                    }
                    {
                      url = "https://www.fool.com/a/feeds/partner/googlechromefollow?apikey=5e092c1f-c5f9-4428-9219-908a47d2e2de";
                      title = "The Motley Fool";
                      limit = 10;
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
