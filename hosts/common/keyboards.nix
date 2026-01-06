{
  config,
  pkgs,
  username,
  ...
}: {
  environment.systemPackages = with pkgs; [
    vial # Open source port of QMK GUI
    qmk # A program to help users work with QMK Firmware
    appimage-run
  ];

  users.users.${username}.extraGroups = ["input"];

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
        game-devices-udev-rules
        logitech-udev-rules
      ];
      extraRules = ''
        # HiDock P1 - allow browser WebUSB access
        SUBSYSTEM=="usb", ATTR{idVendor}=="10d6", ATTR{idProduct}=="b00e", MODE="0666", GROUP="plugdev"
        # HiDock P1 mini - allow browser WebUSB access
        SUBSYSTEM=="usb", ATTR{idVendor}=="3887", ATTR{idProduct}=="2041", MODE="0666", GROUP="plugdev"
      '';
    };
  };
}
