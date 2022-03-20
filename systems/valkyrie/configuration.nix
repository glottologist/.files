{ config, pkgs, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      <nixos-hardware/raspberry-pi/4>
      ./boot.nix
      ./filesystem.nix
      ./hardware.nix
      ./networking.nix
      ./users.nix
      ../../shared/systems/base.nix
      ../../shared/systems/optional/disk.nix
      ../../shared/systems/optional/networktools.nix
      ../../shared/systems/optional/windowmanager/xfce.nix
      ../../shared/systems/optional/specific/k3s.nix
    ];

  system.stateVersion = "22.05"; # Did you read the comment?

}

