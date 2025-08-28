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
trezor-udev-rules
zsa-udev-rules
teensy-udev-rules
picoprobe-udev-rules
numworks-udev-rules
nitrokey-udev-rules
apio-udev-rules
steam-devices-udev-rules
meletrix-udev-rules
uhk-udev-rules
nrf-udev
wooting-udev-rules
usb-blaster-udev-rules
finalmouse-udev-rules
android-udev-rules
game-devices-udev-rules
logitech-udev-rules

      ];
    };
  };
}
