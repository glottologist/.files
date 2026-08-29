{pkgs}:
pkgs.writeShellScriptBin "desktop-reminder" ''
  set -euo pipefail
  rofi="${pkgs.rofi}/bin/rofi"
  action="''${1:-set}"

  case "$action" in
    set)
      mins="$($rofi -dmenu -p 'Remind in minutes')"
      [[ -n "$mins" ]] || exit 0
      msg="$($rofi -dmenu -p 'Reminder message')"
      [[ -n "$msg" ]] || exit 0
      unit="desktop-reminder-$RANDOM"
      ${pkgs.systemd}/bin/systemd-run --user \
        --unit="$unit" \
        --on-active="''${mins}min" \
        ${pkgs.libnotify}/bin/notify-send --urgency=critical "Reminder" "$msg"
      ${pkgs.libnotify}/bin/notify-send "Reminder set" "''${mins}m: $msg"
      ;;
    list)
      ${pkgs.systemd}/bin/systemctl --user list-timers --all \
        | ${pkgs.gnugrep}/bin/grep desktop-reminder || true
      ;;
    clear)
      ${pkgs.systemd}/bin/systemctl --user list-units --all --no-legend \
        | ${pkgs.gnugrep}/bin/grep desktop-reminder \
        | ${pkgs.gawk}/bin/awk '{print $1}' \
        | while read -r unit; do
            ${pkgs.systemd}/bin/systemctl --user stop "$unit" || true
          done
      ${pkgs.libnotify}/bin/notify-send "Reminders" "Cleared"
      ;;
    *)
      echo "usage: desktop-reminder set|list|clear" >&2
      exit 2
      ;;
  esac
''
