{ config, lib, pkgs, modulesPath, ... }:
{


  fileSystems."/" =
    { device = "/dev/disk/by-uuid/3675aa8c-2d11-4068-85bb-e9d9f0f20a8e";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/9774-408C";
      fsType = "vfat";
    };

  swapDevices = [ ];
}
