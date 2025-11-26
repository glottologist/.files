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
    kbfs
    keybase
    keybase-gui
    neomutt
    signal-desktop # signam messenger
    slack-term # Slack client for your term
    telegram-desktop # Telegram Desktop messaging app
    #tuir # Command line reddit - removed: incompatible with Python 3.13
    #turses # A twitter terminal client - removed: incompatible with Python 3.13
  ];
  services = {
  kbfs.enable = true;
    keybase.enable = true; # Keybase is a key directory that maps social media identities to encryption keys in a publicly auditable manner.
  };
}
