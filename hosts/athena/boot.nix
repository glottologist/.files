{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    loader = {
      systemd-boot = {
        enable = lib.mkDefault true;
        configurationLimit = 5;
      };
      efi.canTouchEfiVariables = lib.mkDefault true;
      timeout = 3;
    };
    initrd = {
      availableKernelModules = ["xhci_pci" "ahci" "sd_mod" "raid1"];
      kernelModules = ["dm-raid" "md_mod" "raid1"];
    };
    kernelModules = ["kvm-intel"];
    kernelPackages = pkgs.linuxPackages_6_12;
    kernel.sysctl = {
      "vm.max_map_count" = 2147483642;
      "net.core.rmem_max" = 7500000;
      "net.core.wmem_max" = 7500000;
    };
    swraid = {
      enable = true;
      mdadmConf = "MAILADDR root";
    };
  };
}
