{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    awscli2
    azure-cli
    cloudflared
    k9s
  ];
}
