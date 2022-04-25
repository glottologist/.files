{ config, lib, pkgs, modulesPath, ... }:
{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot = {
    loader = {
       #systemd-boot.enable = true;
       efi.canTouchEfiVariables = true;
       grub = {
          enable = true;
          version = 2;
          efiSupport = true;
          enableCryptodisk = true;
          device = "nodev";
      };
    };
    initrd = {
      availableKernelModules = [
        "ata_piix"
        "ehci_pci"
        "nvme"
        "ohci_pci"
        "rtsx_pci_sdmmc"
        "sd_mod"
        "usb_storage"
        "usbhid"
        "xhci_pci"
      ];
      kernelModules = [ "i915" "dm-snapshot" ];
      luks.devices = {
        crypted = {
          device = "/dev/disk/by-uuid/7da9d6ba-435b-4ed2-b386-1682937e83dc";
          preLVM = true;
        };
      };
    };

    kernel.sysctl = {
       "vm.swappiness" = lib.mkDefault 1;
    };

    kernelParams = lib.mkDefault [ "acpi_rev_override" ];

    kernelModules = [ "kvm-intel" ];
    extraModprobeConfig = ''
      options iwlwifi power_save=1 disable_11ax=1
    '';
  };
}
