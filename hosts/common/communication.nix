{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    slack               # Desktop client for Slack
    thunderbird         # A full-featured e-mail client
    zoom-us             # zoom.us video conferencing application
   ];
}
