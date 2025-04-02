{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    discord # All-in-one cross-platform voice and text chat for gamers
    alpine
    #aerc
    himalaya
    signal-desktop # signam messenger
    #slack # Desktop client for Slack
    slack-term # Slack client for your term
    turses # A twitter terminal client
    tdesktop # Telegram Desktop messaging app
    #thunderbird # A full-featured e-mail client
    tuir # Command line reddit
    msmtp
    #notmuchrev
  ];
  services.imapnotify.enable = true;
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
