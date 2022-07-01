
{ config, lib, pkgs, stdenv, ... }:
{

  imports = [
  ];

  home.packages = with pkgs; [
    #keybase
  ];


  programs = {
  };

  services = {
    keybase.enable = true;  # Keybase is a key directory that maps social media identities to encryption keys in a publicly auditable manner.
    gpg.enable = true;  # Open source encryption
  };
}
