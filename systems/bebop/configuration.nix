{ config, pkgs, ... }:
let
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./boot.nix
      ../../shared/systems/base.nix
      ../../shared/systems/optional/blockchain.nix
      ../../shared/systems/optional/browsers.nix
      ../../shared/systems/optional/communication.nix
      ../../shared/systems/optional/disk.nix
      ../../shared/systems/optional/games.nix
      ../../shared/systems/optional/media.nix
      ../../shared/systems/optional/networktools.nix
      ../../shared/systems/optional/specific/polybar.nix
      ../../shared/systems/optional/storage.nix
      ../../shared/systems/optional/themes.nix
      ../../shared/systems/optional/virtualization.nix
      ../../shared/systems/optional/windowmanager/plasma.nix
      ./filesystem.nix
      ./hardware.nix
      ./networking.nix
      ./users.nix
    ];



  system.stateVersion = "22.05"; # Did you read the comment?

}

