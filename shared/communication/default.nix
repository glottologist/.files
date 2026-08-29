{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    aerc
    alpine
    discord # All-in-one cross-platform voice and text chat for gamers
    localsend # LAN file sharing (Omarchy Share)
    himalaya
    kbfs
    keybase
    keybase-gui
    neomutt
    signal-desktop # signam messenger
    slack-term # Slack client for your term
    teams-for-linux # Unofficial Microsoft Teams client (official client is darwin-only in nixpkgs)
    telegram-desktop
    # WeeChat with the wee-slack plugin baked in: the one terminal Slack
    # client whose auth (xoxc token + xoxd cookie from the browser session)
    # still works, unlike slack-term's dead legacy tokens.
    (weechat.override {
      configure = {availablePlugins, ...}: {
        scripts = with weechatScripts; [wee-slack];
      };
    })
  ];
  services = {
  kbfs.enable = true;
    keybase.enable = true; # Keybase is a key directory that maps social media identities to encryption keys in a publicly auditable manner.
  };
}
