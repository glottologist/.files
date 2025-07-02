{
  inputs,
  config,
  pkgs,
  username,
  ...
}: {
  imports = [
    ./boot.nix
    ./filesystem.nix
    ./fonts.nix
    ./hardware.nix
    ./location.nix
    ./networking.nix
    ./nix.nix
    ./security.nix
    ./services.nix
    ./users.nix
    ./xdg.nix
    ../common/ai.nix
    ../common/blockchain.nix
    ../common/communication.nix
    ../common/default_programs.nix
    ../common/development.nix
    ../common/devices.nix
    ../common/disk.nix
    ../common/games.nix
    ../common/keyboards.nix
    ../common/nix.nix
    ../common/stylix.nix
    ../common/virtualization.nix
  ];
  system = {
    stateVersion = "25.05";
  };
}
