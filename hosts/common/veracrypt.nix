# Nix guideline compliant 2026-09-10
{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.veracrypt ];
}
