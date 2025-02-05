{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
  ipfs
  ];
}
