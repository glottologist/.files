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
    # plymouth = {
    #   enable = true;
    # };
    loader = {
      systemd-boot.enable = lib.mkDefault true;
      efi.canTouchEfiVariables = lib.mkDefault true;
      timeout = 0;
    };
    consoleLogLevel = 0;
    initrd = {
      verbose = false;
      availableKernelModules = ["nvme" "xhci_pci" "thunderbolt" "usb_storage" "usbhid" "sd_mod"];
      kernelModules = [];
      luks.devices."luks-773d6d31-d77e-4c22-b7e2-d904e3901c10".device = "/dev/disk/by-uuid/773d6d31-d77e-4c22-b7e2-d904e3901c10";
    };
    kernelModules = ["kvm-amd" "v4l2loopback"];
    kernelPackages = pkgs.linuxPackages_zen;
    kernel.sysctl = {"vm.max_map_count" = 2147483642;};
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];
    extraModulePackages = [config.boot.kernelPackages.v4l2loopback];
    binfmt.registrations.appimage = {
      wrapInterpreterInShell = false;
      interpreter = "${pkgs.appimage-run}/bin/appimage-run";
      recognitionType = "magic";
      offset = 0;
      mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
      magicOrExtension = ''\x7fELF....AI\x02'';
    };
  };
}
