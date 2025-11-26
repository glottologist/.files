{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    awscli2
    #aws-sam-cli # Broken - dependency version mismatch with click/aws-lambda-builders
    #azure-cli
    cloudflared
    k9s
  ];
}
