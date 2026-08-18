# Bridge ntfy topics into the desktop notification daemon. ntfy is
# publish/subscribe: the phone app rings because it subscribes, and until
# something on the host subscribes too, published alerts never reach the
# desktop. One long-lived `ntfy subscribe` per topic, each message handed to
# notify-send.
#
# Unlike the Pushover bridge there is no session-eviction constraint, so this
# runs on every host without the instances disturbing one another.
{
  pkgs,
  lib,
  ...
}: let
  # Topics to mirror to the desktop. Add a topic here and rebuild.
  topics = [
    "brickborrow-2cacad5ab6eabe61"
  ];

  # ntfy priorities run 1 (min) to 5 (max); notify-send knows three levels.
  onMessage = pkgs.writeShellScript "ntfy-notify-on-message" ''
    export PATH="${lib.makeBinPath [pkgs.libnotify pkgs.coreutils]}:$PATH"
    urgency=normal
    [ "''${NTFY_PRIORITY:-3}" -ge 4 ] && urgency=critical
    [ "''${NTFY_PRIORITY:-3}" -le 2 ] && urgency=low
    exec notify-send -u "$urgency" -a "ntfy" \
      "''${NTFY_TITLE:-$NTFY_TOPIC}" "''${NTFY_MESSAGE:-}"
  '';

  mkSubscriber = topic: {
    name = "ntfy-notify-${topic}";
    value = {
      Unit = {
        Description = "Mirror ntfy topic ${topic} into desktop notifications";
        Documentation = "https://docs.ntfy.sh/subscribe/cli/";
        After = ["graphical-session.target"];
        PartOf = ["graphical-session.target"];
      };

      Service = {
        Type = "simple";
        ExecStart = "${lib.getExe pkgs.ntfy-sh} subscribe ntfy.sh/${topic} ${onMessage}";
        Restart = "on-failure";
        RestartSec = 30;
      };

      Install.WantedBy = ["graphical-session.target"];
    };
  };
in {
  systemd.user.services = lib.listToAttrs (map mkSubscriber topics);
}
