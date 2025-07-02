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
        # font = "Fira Code Light:size=10";
        dpi-aware = "no";
      };
      scrollback.lines = 32768;
      url.launch = "${pkgs.xdg-utils}/bin/xdg-open \${url}";
      tweak.grapheme-shaping = "yes";
      cursor.style = "beam";
    };
  };

  # xdg.configFile."foot/foot-theme.ini".source = ./theme.ini;
  # xdg.configFile."foot/foot.ini".source = ./theme.ini;
}
