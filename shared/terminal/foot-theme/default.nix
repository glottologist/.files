{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
  ];

  xdg.configFile."foot/foot-theme.ini".source = ./theme.ini;
}
