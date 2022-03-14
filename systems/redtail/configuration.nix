{ config, pkgs, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./boot.nix
      ./filesystem.nix
      ./hardware.nix
      ./location.nix
      ./networking.nix
      ./services.nix
      ./users.nix
      ./virtualisation.nix
      ../../shared/systems/optional/virtualization.nix
      ../../shared/systems/optional/browsers.nix
      ../../shared/systems/optional/themes.nix
      ../../shared/systems/optional/networktools.nix
      ../../shared/systems/optional/blockchain.nix
      ../../shared/systems/optional/windowmanager/xmonad.nix
    ];

  system.stateVersion = "21.11"; # Did you read the comment?

}

