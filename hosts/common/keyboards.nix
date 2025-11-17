{
  config,
  pkgs,
  username,
  ...
}: let
  whatpulse = pkgs.appimageTools.wrapType2 {
    pname = "whatpulse";
    version = "5.11";
    src = pkgs.fetchurl {
      url = "https://releases.whatpulse.org/latest/linux/whatpulse-linux-latest_amd64.AppImage";
      sha256 = "0g8bvzc0ks2xa9mrnx46ksid3d5x4x4fy8dswrxwva6l4ffx74lw";
    };
  };
in {
  environment.systemPackages = with pkgs; [
    vial # Open source port of QMK GUI
    qmk # A program to help users work with QMK Firmware
    appimage-run
    whatpulse
    # Required for WhatPulse AppImage to function properly
    xorg.libX11
    xorg.libXtst
    xorg.libXi
    qt6.qtwayland
  ];

  systemd.user.services.whatpulse = {
    description = "WhatPulse client";
    wantedBy = ["graphical-session.target"];
    after = ["graphical-session.target" "hyprland-session.target"];
    partOf = ["graphical-session.target"];

    serviceConfig = {
      ExecStart = "${whatpulse}/bin/whatpulse";
      Restart = "on-failure";
      RestartSec = "5s";
      # Run in the same environment as other graphical applications
      Type = "simple";
    };
  };

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
        android-udev-rules
        game-devices-udev-rules
        logitech-udev-rules
      ];
    };
  };
}
