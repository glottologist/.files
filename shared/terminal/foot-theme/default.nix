{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
  ];

  xdg.configFile."foot/foot-theme.ini".source = ./theme.ini;
  xdg.configFile."foot/foot.ini".source = ./theme.ini;
}
