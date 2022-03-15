{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    discord         # All-in-one cross-platform voice and text chat for gamers
    skypeforlinux   # Linux client for Skype
    slack           # Desktop client for Slack
    slack-term      # Slack client for your term
    thunderbird     # A full-featured e-mail client
    zoom-us         # zoom.us video conferencing application
   ];
}
