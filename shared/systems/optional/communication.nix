{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    discord         # All-in-one cross-platform voice and text chat for gamers
    matterbridge    # Simple bridge between Mattermost, IRC, XMPP, Gitter, Slack, Discord, Telegram, Rocket.Chat, Hipchat(via xmpp), Matrix and Steam
    mattermost      # Open-source Slack-alternative
    skypeforlinux   # Linux client for Skype
    slack           # Desktop client for Slack
    slack-term      # Slack client for your term
    tdesktop        # Telegram Desktop messaging app
    thunderbird     # A full-featured e-mail client
    zoom-us         # zoom.us video conferencing application
   ];
}
