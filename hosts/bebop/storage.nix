
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  environment.systemPackages = with pkgs; [
    dropbox-cli # For command-line management
  ];

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [17500];
    allowedUDPPorts = [17500];
    # Allow Twingate connections (it needs outbound, which is allowed by default)
    checkReversePath = false; # Disable reverse path filtering for VPN compatibility
  };

  systemd.user.services.dropbox = {
    description = "Dropbox";
    wantedBy = ["graphical-session.target"];

    environment = {
      QT_PLUGIN_PATH = "/run/current-system/sw/" + pkgs.qt5.qtbase.qtPluginPrefix;
      QML2_IMPORT_PATH = "/run/current-system/sw/" + pkgs.qt5.qtbase.qtQmlPrefix;
    };

    serviceConfig = {
      ExecStart = "${lib.getBin pkgs.dropbox}/bin/dropbox";
      ExecReload = "${lib.getBin pkgs.coreutils}/bin/kill -HUP $MAINPID";
      KillMode = "control-group";
      Restart = "on-failure";
      PrivateTmp = true;
      ProtectSystem = "full";
      Nice = 10;
    };
  };
}
