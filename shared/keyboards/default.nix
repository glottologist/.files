{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
     vial          # Open source port of QMK GUI
    qmk           # A program to help users work with QMK Firmware

  ];
}
