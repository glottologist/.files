{ config, pkgs, ... }:
{

  environment.systemPackages =  with pkgs; [
    #via           # GUI to program keyboard firmware
    vial          # Open source port of QMK GUI
    qmk           # A program to help users work with QMK Firmware
   ];
  services = {
    udev = {
      packages = with pkgs; [
        teck-udev-rules
        wooting-udev-rules
        logitech-udev-rules
        qmk-udev-rules
      ];
    };
  };


}
