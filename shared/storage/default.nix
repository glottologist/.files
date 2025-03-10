{
  config,
  lib,
  pkgs,
  stdenv,
  ...
}: {

systemd.user.services.dropbox = {
        Unit = {
            Description = "Dropbox service";
        };
        Install = {
            WantedBy = [ "default.target" ];
        };
        Service = {
            ExecStart = "${pkgs.dropbox}/bin/dropbox";
            Restart = "on-failure";
        };
    };

  home.packages = with pkgs; [
  ];

  imports = [
  ];
}
