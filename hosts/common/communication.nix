{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    slack               # Desktop client for Slack
    #turses              # A twitter terminal client - removed: incompatible with Python 3.13
    thunderbird         # A full-featured e-mail client
    #tuir                # Command line reddit - removed: incompatible with Python 3.13
    zoom-us             # zoom.us video conferencing application
   ];
}
