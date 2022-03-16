{ config, lib, pkgs, modulesPath, ... }:
{


  fileSystems = {
       "/" = {
         device = "/dev/disk/by-uuid/44444444-4444-4444-8888-888888888888";
         fsType = "ext4";
        };

       "/railgun" = {
          device = "/dev/disk/by-uuid/5b3f529f-da78-4a69-a642-d7e2aad14288";
          fsType = "ext4";
       };
   };

  swapDevices = [ ];
}
