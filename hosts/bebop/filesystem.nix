{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {


  fileSystems."/" =
    { device = "/dev/disk/by-uuid/c0586a48-c5c7-4f82-a559-5839d2631d8f";
      fsType = "ext4";
    };


  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/3A90-56B9";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  swapDevices = [ ];
}
