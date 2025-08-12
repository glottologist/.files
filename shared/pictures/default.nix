{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    feh
    gthumb
    shotwell
    xfce.ristretto
    imagemagick

  ];

  xdg.dataFile."noahisla.png".source = ./noahisla.png;
  xdg.dataFile."foreverlife.png".source = ./foreverlife.png;
}
