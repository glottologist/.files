{ config, lib, pkgs, inputs, ... }:
{
  imports =
    [
      ./base/services.nix
      ./base/nix.nix
      ./base/cachix.nix
      ./base/location.nix
      ./base/environment.nix
      ./base/programs.nix
      ./base/programs.nix
      ./optional/virtualization.nix
    ];

}
