{ config, lib, pkgs, inputs, ... }:
{
  imports =
    [
      ./services.nix
      ./nix.nix
      ./cachix.nix
      ./location.nix
      ./environment.nix
      ./programs.nix
      ./users.nix
    ];

}
