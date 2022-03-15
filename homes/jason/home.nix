{ config, lib, pkgs, stdenv, ... }:

let
  defaultPkgs = with pkgs; [
    any-nix-shell        # fish support for nix shell
  ];

in
{
  programs.home-manager.enable = true;

  #nixpkgs.overlays = [
  #];

  imports = (import ./imports.nix);

  xdg.enable = true;

  home = {
    packages = defaultPkgs;

    sessionVariables = {
      DISPLAY = ":0";
      EDITOR = "nvim";
    };
  };


  # Make home manager news silent
  news.display = "silent";

}
