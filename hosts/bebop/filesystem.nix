{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  fileSystems."/" =
    { device = "/dev/disk/by-uuid/6799ae1b-2320-48c3-b253-7f1dc13f1ddb";
      fsType = "ext4";
    };

  boot.initrd.luks.devices."luks-773d6d31-d77e-4c22-b7e2-d904e3901c10".device = "/dev/disk/by-uuid/773d6d31-d77e-4c22-b7e2-d904e3901c10";

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/F2E3-D7A7";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  swapDevices = [ ];
}
