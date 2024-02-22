{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
  ];

  xdg.configFile."foot-theme.ini".source = ./theme.ini;
}
