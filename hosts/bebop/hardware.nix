{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  hardware = {
    ledger.enable = true; # Enables udev rules for Ledger hardware wallets

    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    sane = {
      enable = true;
      extraBackends = [pkgs.sane-airscan];
      disabledDefaultBackends = ["escl"];
    };
    logitech.wireless.enable = false;
    logitech.wireless.enableGraphical = false;
    graphics.enable = true;
    enableRedistributableFirmware = true;
    keyboard.qmk.enable = true;
    bluetooth.enable = true;
    bluetooth.powerOnBoot = true;
  };

  # systemd-rfkill restores saved rfkill state at boot, overriding
  # hardware.bluetooth.powerOnBoot — a Bluetooth soft-block then
  # survives reboot. Disable persistence so powerOnBoot always wins.
  systemd.services.systemd-rfkill.enable = false;
  systemd.sockets.systemd-rfkill.enable = false;

  # MT7922 Bluetooth (USB 0e8d:e616): a btmtk regression from kernel
  # 7.0.7 wedges the controller ("Failed to send wmt func ctrl -22")
  # when the USB device autosuspends. Pin power on so the driver can
  # always reach it.
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0e8d", ATTR{idProduct}=="e616", TEST=="power/control", ATTR{power/control}="on"
  '';
}
