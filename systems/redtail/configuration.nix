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
    ];

  system.stateVersion = "21.11"; # Did you read the comment?

}

