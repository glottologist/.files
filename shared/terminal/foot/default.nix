{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
  ];

  programs.foot = {
    enable = true;
    # enableBashIntegration = true;
    # enableFishIntegration = true;
    server.enable = true;
    settings = {
      main = {
        term = "xterm-256color";
        pad = "27x27";
        font = "Fira Code Light:size=10";
        dpi-aware = "no";
      };
      scrollback.lines = 32768;
      url.launch = "${pkgs.xdg-utils}/bin/xdg-open \${url}";
      tweak.grapheme-shaping = "yes";
      cursor.style = "beam";
      colors = {
        foreground = "4c4f69";
        background = "eff1f5";
        regular0 = "5c5f77";
        regular1 = "d20f39";
        regular2 = "40a02b";
        regular3 = "df8e1d";
        regular4 = "1e66f5";
        regular5 = "ea76cb";
        regular6 = "179299";
        regular7 = "acb0be";
        bright0 = "6c6f85";
        bright1 = "d20f39";
        bright2 = "40a02b";
        bright3 = "df8e1d";
        bright4 = "1e66f5";
        bright5 = "ea76cb";
        bright6 = "179299";
        bright7 = "bcc0cc";
        selection-foreground = "4c4f69";
        selection-background = "ccced7";
        search-box-no-match = "dce0e8 d20f39";
        search-box-match = "4c4f69 ccd0da";
        jump-labels = "dce0e8 fe640b";
        urls = "1e66f5";
      };
    };
  };

  # xdg.configFile."foot/foot-theme.ini".source = ./theme.ini;
  # xdg.configFile."foot/foot.ini".source = ./theme.ini;
}
