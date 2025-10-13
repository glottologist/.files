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
      systemd-boot = {
	  enable = lib.mkDefault true;
	  configurationLimit = 2;
	  };
      efi.canTouchEfiVariables = lib.mkDefault true;
      timeout = 0;
    };
    consoleLogLevel = 0;
    initrd = {
      verbose = false;
      availableKernelModules = ["nvme" "xhci_pci" "thunderbolt" "usb_storage" "usbhid" "sd_mod"];
      kernelModules = [];
      luks.devices."luks-82f26c36-a2bc-41a5-872c-20121af02fd2".device = "/dev/disk/by-uuid/82f26c36-a2bc-41a5-872c-20121af02fd2";

    };
    kernelModules = ["kvm-amd" "v4l2loopback"];
    kernelPackages = pkgs.linuxPackages_zen;
    extraModprobeConfig = ''
      # Fix MediaTek MT7925e wifi disconnection issues
      options mt7925e disable_aspm=1
    '';
    kernel.sysctl = {"vm.max_map_count" = 2147483642;};
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
      "pcie_aspm=off"
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
