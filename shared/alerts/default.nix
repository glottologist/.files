{
  pkgs,
  lib,
  ...
}: let
  paths = import ./paths.nix;

  # Kept apart from the claude-code topic so that a chatty third-party
  # integration cannot bury the agent notifications, and so either stream may
  # be muted on the phone independently of the other.
  ntfyTopic = "pushover-glottologist";

  python = pkgs.python3.withPackages (ps: [ps.websocket-client]);

  bridge = pkgs.writeShellScriptBin "pushover-bridge" ''
    export PATH="${lib.makeBinPath [pkgs.libnotify pkgs.procps]}:$PATH"
    exec ${python}/bin/python3 ${../../secrets/alerts/pushover-bridge.py} "$@"
  '';

  register = pkgs.writeShellScriptBin "pushover-register" ''
    export PATH="${lib.makeBinPath [pkgs.curl pkgs.jq pkgs.gnugrep pkgs.coreutils]}:$PATH"
    exec ${pkgs.bash}/bin/bash ${../../secrets/alerts/pushover-register.sh} "$@"
  '';
in {
  home.packages = [bridge register];

  systemd.user.services.pushover-bridge = {
    Unit = {
      Description = "Bridge Pushover Open Client messages into the local alert sinks";
      Documentation = "https://pushover.net/api/client";
      # One registration may hold only one live session; were the bridge to run
      # on athena and hermes as well, the three would evict one another in turn
      # and Pushover would answer each eviction with an 'A' frame.
      ConditionHost = "bebop";
      After = ["graphical-session.target"];
      PartOf = ["graphical-session.target"];
    };

    Service = {
      Type = "simple";
      ExecStart = "${bridge}/bin/pushover-bridge";
      Environment = [
        "PUSHOVER_NTFY_TOPIC=${ntfyTopic}"
        "PUSHOVER_NTFY_TOKEN_FILE=${../../secrets/ntfy-key.txt}"
        "PUSHOVER_STATE_FILE=${paths.stateFileSystemd}"
        "PUSHOVER_WAYBAR_SIGNAL=RTMIN+${toString paths.waybarSignal}"
      ];
      Restart = "on-failure";
      RestartSec = 10;
      # 78 is raised for a rejected session or a stolen registration. Neither
      # mends itself, so restarting would only spin.
      RestartPreventExitStatus = 78;
    };

    Install.WantedBy = ["graphical-session.target"];
  };
}
