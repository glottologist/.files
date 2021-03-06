{ config, pkgs, ... }:

{
  systemd.user.services.polybar = {
    enable = true;
    description = "Polybar";
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.polybar}/bin/polybar -c /etc/nixos/config/polybar example";
      Restart = "on-abnormal";
    };
  };

  environment.systemPackages = with pkgs; [
    polybar
  ];

}

