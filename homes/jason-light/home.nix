{ config, lib, pkgs, stdenv,  ... }:

let
  defaultPkgs = with pkgs; [
    any-nix-shell        # fish support for nix shell
  ];

in
{
  programs.home-manager.enable = true;

  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [
         "electron-12.2.3"
         "electron-13.6.9"
         "libgit2-0.27.10"
         "python2.7-Pillow-6.2.2"
    ];
  };
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
