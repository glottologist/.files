{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    aerc
    alpine
    discord # All-in-one cross-platform voice and text chat for gamers
    grpcurl
    himalaya
    keybase
    keybase-gui
    neomutt
    signal-desktop # signam messenger
    slack-term # Slack client for your term
    tdesktop # Telegram Desktop messaging app
    tuir # Command line reddit
    turses # A twitter terminal client
    msmtp
  ];
  services = {
    keybase.enable = true; # Keybase is a key directory that maps social media identities to encryption keys in a publicly auditable manner.
     imapnotify.enable = true;
  };
  # programs.mbsync = {
  #   enable = true;
  #   extraConfig = ''
  #     SyncState *
  #   '';
  # };
  # services.mbsync = {
  #   enable = false;
  #   #configFile = /home/zarred/.config/isync/mbsyncrc;
  #   frequency = "*:0/30";
  #   verbose = true;
  # };
  programs.msmtp.enable = true;
  # programs.notmuch = {
  #   enable = true;
  #   hooks = {
  #     preNew = "mbsync --all";
  #   };
  # };
  #
  # programs.neomutt = {
  #   enable = true;
  #   vimKeys = true;
  #   sidebar = {
  #     enable = true;
  #   };
  #   settings = {
  #     sort = "threads";
  #     sort_aux = "reverse-last-date-received";
  #     mark_old = "no";
  #     mail_check = "90";
  #     timeout = "15";
  #   };
  # };
}
