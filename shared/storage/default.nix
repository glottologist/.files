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
  home.packages = with pkgs; [
    maestral-gui
    maestral
    xivlauncher
  ];

  imports = [
  ];
}
