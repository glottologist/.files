{ config, lib, pkgs, inputs, ... }:
{
  imports =
    [
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
