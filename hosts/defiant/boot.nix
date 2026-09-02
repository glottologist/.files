# Defiant's firmware is legacy BIOS: the live Debian image has no
# /sys/firmware/efi, so GRUB installs to the disk's MBR and boots through the
# EF02 partition that hosts/common/hetzner-disk.nix creates.
{ ... }:
{
  # The disk itself is not named here: disko declares
  # boot.loader.grub.devices from the EF02 partition it creates, and setting
  # grub.device as well makes /dev/sda a duplicate entry in mirroredBoots,
  # which NixOS rejects.
  boot.loader.grub = {
    enable = true;
    efiSupport = false;
  };
  boot.loader.timeout = 3;
}
