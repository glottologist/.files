{pkgs, lib, config, modulesPath, ...}:
{
  imports = [
    "${modulesPath}/installer/cd-dvd/iso-image.nix"
    "${modulesPath}/profiles/all-hardware.nix"
    "${modulesPath}/profiles/base.nix"
    "${modulesPath}/profiles/installation-device.nix"
    ./wm.nix
    ./user.nix
    ./scripts.nix
    ./packages.nix
  ];

  isoImage.makeEfiBootable = true;
  isoImage.makeUsbBootable = true;

  networking.networkmanager.enable = true;
  networking.wireless.enable = false;

  boot.loader.grub.memtest86.enable = true;

  services.sshd.enable = true;

  system.stateVersion = "21.11";

  nix = {
    extraOptions = "experimental-features = nix-command flakes";
    package = pkgs.nixUnstable;
  };

}
