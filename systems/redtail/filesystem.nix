{ config, lib, pkgs, modulesPath, ... }:
{

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/fbc9a1c1-e1d7-435d-bd60-790b0b8433f6";
      fsType = "ext4";
    };

  swapDevices = [ ];
}
