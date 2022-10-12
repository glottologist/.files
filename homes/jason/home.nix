{ config, lib, pkgs, stdenv,  ... }:

let
  username = "jason";
  homeDirectory = "/home/${username}";
  configHome = "${homeDirectory}/.config";

  defaultPkgs = with pkgs; [
    any-nix-shell        # fish support for nix shell
  ];

in
{
  programs.home-manager = {
    enable = true;
  };

  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [
         "electron-12.2.3"
         "electron-13.6.9"
         "libgit2-0.27.10"
         #"python2.7-Pillow-6.2.2"
    ];
  };
  #nixpkgs.overlays = [
  #];

  imports = (import ./imports.nix);

  xdg = {
    inherit configHome;
    enable = true;
  };
  home = {
    inherit username homeDirectory;

    packages = defaultPkgs;

    sessionVariables = {
      DISPLAY = ":0";
      EDITOR = "nvim";
    };

    stateVersion = "22.05";
  };


  # Make home manager news silent
  news.display = "silent";

}
