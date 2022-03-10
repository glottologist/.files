{ config, lib, pkgs, inputs, ... }:

let
  basefonts = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
    cascadia-code
    fira-code
    fira-code-symbols
    fira-mono
    font-awesome-ttf
    nerdfonts
  ];
in
{
  imports =
    [
      ./services.nix
      ./nix.nix
      ./cachix.nix
      ./location.nix
      ./packages.nix
    ];

  fonts.fonts = with pkgs; [
    basefont
  ];

  system.stateVersion = "22.05";

}
