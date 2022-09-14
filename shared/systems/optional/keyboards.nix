{ config, pkgs, ... }:
{

  environment.systemPackages =  with pkgs; [
    via           # GUI to program keyboard firmware
    vial          # Open source port of QMK GUI
   ];
  services = {
    udev = {
      packages = with pkgs; [
        uhk-udev-rules
        teck-udev-rules
        wooting-udev-rules
        logitech-udev-rules
        qmk-udev-rules
      ];
    };
  };


}
