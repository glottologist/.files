#!/usr/bin/env bash
set -euo pipefail

HYPRCTL="${HYPRCTL:-hyprctl}"
action="${1:-}"

case "$action" in
  copy | cut | paste) ;;
  *)
    echo "usage: unified-clipboard copy|cut|paste" >&2
    exit 2
    ;;
esac

json="$("$HYPRCTL" activewindow -j)"
is_terminal=0
if printf '%s' "$json" | grep -q '"terminal"'; then
  is_terminal=1
fi

if [[ "$action" == "cut" && "$is_terminal" -eq 1 ]]; then
  exit 0
fi

mod="CTRL"
key="C"
case "$action" in
  cut) key="X" ;;
  paste) key="V" ;;
esac
if [[ "$is_terminal" -eq 1 ]]; then
  mod="CTRL_SHIFT"
fi

"$HYPRCTL" dispatch sendshortcut "${mod},${key},activewindow"
