{ config, lib, pkgs, modulesPath, ... }:
{
  imports = [ ];

  boot = {
    loader = {
       grub = {
         enable = false;
       };
       raspberryPi = {
         enable = true;
         version = 4;
       };
     };
    initrd = {
      availableKernelModules = [ "xhci_pci" "usbhid" ];
      kernelModules = [ ];
    };

     kernelModules = [ ];
     kernelPackages = pkgs.linuxPackages_rpi4;
     extraModulePackages = [ ];
  };

}
