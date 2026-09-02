# Reliant's firmware is UEFI: /sys/firmware/efi is present on the live Debian
# image, and the ESP that hosts/common/hetzner-disk.nix creates is mounted at
# /boot.
{ ... }:
{
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    timeout = 3;
  };
}
