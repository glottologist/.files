{
  config,
  lib,
  pkgs,
  stdenv,
  ...
}: {

 systemd.user.services.dropbox = {
      Unit = {Description = "dropbox";};

      Install = {WantedBy = ["graphical-session.target"];};

      Service = {
        Environment = [
        ];

        Restart = "on-failure";
        PrivateTmp = true;
        ProtectSystem = "full";
        Nice = 10;

        ExecStart = "${lib.getBin pkgs.dropbox}/bin/dropbox";
        ExecReload = "${lib.getBin pkgs.coreutils}/bin/kill -HUP $MAINPID";
        ExecStop = "${lib.getBin pkgs.dropbox-cli}/bin/dropbox stop";
        KillMode = "control-group";
      };
    };
    home.packages = [pkgs.dropbox-cli];

  imports = [
  ];
}
