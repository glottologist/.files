{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
     brave       # Privacy-oriented browser for Desktop and Laptop computers
     firefox     # A web browser built from Firefox source tree
   ];
}
