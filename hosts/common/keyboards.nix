{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    vial # Open source port of QMK GUI
    qmk # A program to help users work with QMK Firmware
  ];
  services = {
    udev = {
      packages = with pkgs; [
        logitech-udev-rules
        qmk-udev-rules
      ];
    };
  };
}
