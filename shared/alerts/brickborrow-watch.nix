{
  pkgs,
  lib,
  ...
}: {
  home.packages = [pkgs.brickborrow-watch];

  systemd.user.services.brickborrow-watch = {
    Unit = {
      Description = "Check Brick Borrow for newly available sets";
      # One host only: three laptops polling the same catalogue would fire
      # the same ntfy alert three times.
      ConditionHost = "bebop";
    };

    Service = {
      Type = "oneshot";
      ExecStart = lib.getExe pkgs.brickborrow-watch;
      # SMTP password (and any later ntfy token) stay out of the Nix store.
      EnvironmentFile = "%h/.config/brickborrow-watch/secrets.env";
    };
  };

  systemd.user.timers.brickborrow-watch = {
    Unit = {
      Description = "Poll Brick Borrow for newly available sets";
      ConditionHost = "bebop";
    };

    Timer = {
      OnBootSec = "2m";
      OnUnitActiveSec = "5m";
      Persistent = true;
    };

    Install.WantedBy = ["timers.target"];
  };
}
