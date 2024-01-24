{
  config,
  pkgs,
  ...
}: let
in {
  imports = [
    # Include the results of the hardware scan.
    ./boot.nix
    ./location.nix
    ../../shared/systems/base.nix
    ../../shared/systems/optional/blockchain.nix
    ../../shared/systems/optional/communication.nix
    ../../shared/systems/optional/disk.nix
    ../../shared/systems/optional/games.nix
    ../../shared/systems/optional/keyboards.nix
    ../../shared/systems/optional/media.nix
    ../../shared/systems/optional/networktools.nix
    ../../shared/systems/optional/pentesting.nix
    ../../shared/systems/optional/scripts/all.nix
    ../../shared/systems/optional/specific/waydroid.nix
    ../../shared/systems/optional/specific/devenv.nix
    ../../shared/systems/optional/storage.nix
    ../../shared/systems/optional/themes.nix
    ../../shared/systems/optional/virtualization.nix
    #../../shared/systems/optional/windowmanager/plasma.nix
    ../../shared/systems/optional/windowmanager/xfce.nix
    ../../shared/systems/optional/windowmanager/hyprland
    ./environment.nix
    ./filesystem.nix
    ./hardware.nix
    ./networking.nix
    ./services.nix
    ./users.nix
  ];
  system = {
    autoUpgrade.enable = true;
    autoUpgrade.allowReboot = true;
    stateVersion = "23.05";
  };
}
