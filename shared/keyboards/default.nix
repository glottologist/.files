{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    diskonaut # Terminal disk space navigator


    vial          # Open source port of QMK GUI
    qmk           # A program to help users work with QMK Firmware

  ];
}
