{ inputs, config, lib, pkgs, stdenv,  ... }:

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

  imports =  [
  ../../shared/home/cryptography/default.nix
  ../../shared/home/development/default.nix
  ../../shared/home/editing/default.nix
  ../../shared/home/languages/all.nix
  ../../shared/home/learning/default.nix
  ../../shared/home/blockchain/default.nix
  ../../shared/home/cloud/default.nix
  ../../shared/home/database/default.nix
  ../../shared/home/documentation/default.nix
  ../../shared/home/fonts/default.nix
  ../../shared/home/network/default.nix
  ../../shared/home/security/default.nix
  ../../shared/home/services/polybar/default.nix
  ../../shared/home/productivity/default.nix
  ../../shared/home/terminal/default.nix
  ];


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

    stateVersion = "23.05";
  };


  # Make home manager news silent
  news.display = "silent";

}
