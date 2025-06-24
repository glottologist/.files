{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    aerc
    alpine
    discord # All-in-one cross-platform voice and text chat for gamers
    himalaya
    keybase
    keybase-gui
    neomutt
    signal-desktop # signam messenger
    slack-term # Slack client for your term
    tdesktop # Telegram Desktop messaging app
    tuir # Command line reddit
    turses # A twitter terminal client
  ];
  services = {
    keybase.enable = true; # Keybase is a key directory that maps social media identities to encryption keys in a publicly auditable manner.
  };
}
