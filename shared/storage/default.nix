{
  config,
  lib,
  pkgs,
  stdenv,
  ...
}: {
  systemd.user.services.maestral = {
    Unit = {
      Description = "Maestral daemon";
      After = ["graphical-session-pre.target"];
      PartOf = ["graphical-session.target"];
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
    Service = {
      ExecStart = "${pkgs.maestral}/bin/maestral start -f";
      ExecStop = "${pkgs.maestral}/bin/maestral stop";
      Restart = "on-failure";
      Nice = 10;
    };
  };
  systemd.user.services.maestral-gui = {
    Unit = {
      Description = "Maestral GUI daemon";
      After = ["graphical-session-pre.target"];
      PartOf = ["graphical-session.target"];
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
    Service = {
      ExecStart = "${pkgs.maestral-gui}/bin/maestral_qt";
      ExecReload = "${pkgs.util-linux}/bin/kill -HUP $MAINPID";
      KillMode = "process";
      Restart = "on-failure";
    };
  };
  home.packages = with pkgs; [
    dropbox-cli
    maestral-gui
    maestral
  ];

  imports = [
  ];
}
