{ config, lib, pkgs, inputs, ... }:
let
  folder = ./cachix;
  toImport = name: value: folder + ("/" + name);
  filterCaches = key: value: value == "regular" && lib.hasSuffix ".nix" key;
  imports = lib.mapAttrsToList toImport (lib.filterAttrs filterCaches (builtins.readDir folder));
in
{
  inherit imports;
  nixpkgs.config = {
    allowUnfree = true;
    #allowBroken = true;
    permittedInsecurePackages = [
         "electron-12.2.3"
         "electron-13.6.9"
         "libgit2-0.27.10"
         "python2.7-Pillow-6.2.2"
         "adobe-reader-9.5.5"
    ];
  };
  environment.systemPackages = with pkgs; [
    nox        # Tools to make nix nicer to use
    nix-tree   # Interactively browse a Nix store paths dependencies
  ];

  # Nix daemon config
  nix = {
    # Automate garbage collection
    gc = {
      automatic = true;
      dates     = "weekly";
      options   = "--delete-older-than 7d";
    };

    # Flakes settings
    #package = pkgs.nixUnstable;
    package = pkgs.nixVersions.unstable;

    registry.nixpkgs.flake = inputs.nixpkgs;
    # Avoid unwanted garbage collection when using nix-direnv
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs          = true
      keep-derivations      = true
      binary-caches-parallel-connections = 3
      connect-timeout = 5
    '';

    sshServe = {
      enable = true;
      keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILN1szb/fBxMMUgpClXaFd4zR71B5/02Ij9jV4wxKW+o jason@glottologist.co.uk" ];
    };

    settings = {
      # Automate `nix store --optimise`
      auto-optimise-store = true;

      # Required by Cachix to be used as non-root user
      trusted-users = [ "root" "jason" ];

      substituters = [
        "https://nix-community.cachix.org"
        "https://cache.nixos.org/"
        "http://cache.glottologist.co.uk"
      ];

      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.glottologist.co.uk:eQt44dcxTWb08LWllIfi5Vagt0V4rOYyWQMxbqP/eAQ="
      ];

      experimental-features = ["nix-command" "flakes"];

      keep-outputs                 = true;
      keep-derivations             = true;
      allow-import-from-derivation = true;



    };
  };
}
