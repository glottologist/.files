{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    discord             # All-in-one cross-platform voice and text chat for gamers
    slack               # Desktop client for Slack
    slack-term          # Slack client for your term
    #turses              # A twitter terminal client - removed: incompatible with Python 3.13
    telegram-desktop    # Telegram Desktop messaging app
    thunderbird         # A full-featured e-mail client
    #tuir                # Command line reddit - removed: incompatible with Python 3.13
    zoom-us             # zoom.us video conferencing application
   ];
}
