# The partitions Chimera actually has, which are not the ones disko.nix
# describes.
#
# The machine was already running a stock NixOS 26.05 install when this
# configuration was applied to it, and the choice was made to switch that
# install in place rather than erase it. The layout is therefore the graphical
# installer's own: a 1G ESP on /boot, an ext4 root filling the 2TB NVMe, and an
# 8.8G swap partition beside them. Nothing is encrypted.
#
# disko.nix stays beside this file and is deliberately not imported. It
# describes the LUKS2 and LVM layout the machine would take if it were ever
# reinstalled from bare metal, which is the design the README argues for; the
# two files are alternatives rather than layers, and importing both would hand
# the filesystem definitions to a layout that does not exist on this disk.
#
# The cost of the in-place install is worth stating where it will be read: the
# root filesystem is plaintext, so the OpenAI and Grok keys that homes/jrt
# writes into the Nix store are readable by anyone who takes the machine apart.
# Bootstrapping from disko.nix is what removes that exposure.
{ ... }:
{
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/0ec598e2-deba-497d-94e7-4f93f2d19b8a";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/9703-5B0A";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/f069ed7d-1c0a-46fe-8faf-e3c7f37961f7"; }
  ];
}
