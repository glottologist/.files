{ config, lib, pkgs, modulesPath, ... }:
{


  fileSystems = {
       "/" = {
         device = "/dev/disk/by-label/NIXOS_SD";
         fsType = "ext4";
        };

       "/turbojet" = {
          device = "/dev/disk/by-uuid/11a3e4cd-6f03-4e09-b175-78fd93ef3e29";
          fsType = "ext4";
       };
   };

  swapDevices = [ ];
}
