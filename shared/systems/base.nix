{ config, lib, pkgs, inputs, ... }:
{
  imports =
    [
      ./base/cachix.nix
      ./base/devices.nix
      ./base/environment.nix
      ./base/location.nix
      ./base/nix.nix
      ./base/programs.nix
      ./base/services.nix
      ./base/sound.nix
      ./base/users.nix
    ];

}
