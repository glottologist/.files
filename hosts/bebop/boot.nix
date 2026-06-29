{
  config,
  lib,
  pkgs,
  modulesPath,
  btKernelPackages,
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
	  # 96M ESP is shared with Windows (~30M), leaving ~66M for NixOS. One
	  # generation (initrd 28M + kernel 13M ≈ 41M) fits; two (~69M) overflow
	  # the partition and the bootloader install fails on initrd copy.
	  configurationLimit = 1;
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
    kernelModules = ["kvm-amd" "v4l2loopback" "mt7921e"];
    # MT7922 Bluetooth regression: a btmtk change after Linux 7.0.3 breaks
    # the WMT firmware handshake ("hci0: Failed to send wmt func ctrl -22")
    # and the controller never initialises. Verified: 7.0.3 works, while
    # 6.18.32 and 7.0.9 both fail (the bad commit is in 6.18-stable too).
    # USB autosuspend was ruled out by direct test. Pinned to 7.0.3 — the
    # last proven-good kernel — via the nixpkgs-bt-kernel flake input;
    # revert to pkgs.linuxPackages_latest once fixed upstream.
    kernelPackages = btKernelPackages;
    extraModprobeConfig = ''
      # Fix MediaTek MT7925e wifi disconnection issues
      options mt7925e disable_aspm=1
      # Fix MediaTek MT7922/MT7921 wifi disconnection issues
      options mt7921e disable_aspm=1
    '';
    kernel.sysctl = {
      "vm.max_map_count" = 2147483642;
      "net.core.rmem_max" = 7500000;
      "net.core.wmem_max" = 7500000;
    };
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
      "pcie_aspm=off"
      # AMD Strix Point GPU fixes
      "amdgpu.sg_display=0"
      "amdgpu.dcdebugmask=0x10"
      "amdgpu.gpu_recovery=1"
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
