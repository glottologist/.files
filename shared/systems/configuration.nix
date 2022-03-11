{ config, lib, pkgs, inputs, ... }:

let
  basefonts = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
    fira-code
    fira-code-symbols
    fira-mono
    font-awesome
  ];
in
{
  imports =
    [
      ./services.nix
      ./nix.nix
      ./cachix.nix
      ./location.nix
      ./environment.nix
      ./programs.nix
    ];

  fonts.fonts = with pkgs; [
    basefonts
  ];


}
