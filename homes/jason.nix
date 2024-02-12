{
  inputs,
  config,
  lib,
  pkgs,
  stdenv,
  ...
}: let
  username = "jason";
  homeDirectory = "/home/${username}";
  configHome = "${homeDirectory}/.config";

  defaultPkgs = with pkgs; [
    any-nix-shell # fish support for nix shell
  ];
in {
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

  imports = [
    ../../shared/cryptography/default.nix
    ../../shared/browsers/default.nix
    ../../shared/development/default.nix
    ../../shared/editing/default.nix
    ../../shared/languages/all.nix
    ../../shared/learning/default.nix
    ../../shared/blockchain/default.nix
    ../../shared/cloud/default.nix
    ../../shared/database/default.nix
    ../../shared/documentation/default.nix
    ../../shared/fonts/default.nix
    ../../shared/network/default.nix
    ../../shared/security/default.nix
    ../../shared/services/default.nix
    ../../shared/productivity/default.nix
    ../../shared/terminal/default.nix
    ../../shared/windowmanager/backgrounds/default.nix
    ../../shared/windowmanager/hyprland/default.nix
    ../../shared/windowmanager/eww/default.nix
    ../../shared/windowmanager/waybar/default.nix
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
    pointerCursor = {
      gtk.enable = true;
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 22;
    };
    stateVersion = "23.05";
  };

  # Make home manager news silent
  news.display = "silent";
}
