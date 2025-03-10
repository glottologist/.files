{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
  ];

  xdg.dataFile."noahisla.png".source = ./noahisla.png;
  xdg.dataFile."foreverlife.png".source = ./foreverlife.png;
}
