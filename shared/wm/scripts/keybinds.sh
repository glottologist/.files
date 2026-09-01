#!/usr/bin/env bash
set -euo pipefail

HYPRCTL="${HYPRCTL:-hyprctl}"
ROFI="${ROFI:-rofi}"

usage() {
  echo "usage: list-keybinds [--print]" >&2
  exit 2
}

format_bindings() {
  awk '
    function add_modifier(current, modifier) {
      return current == "" ? modifier : current "+" modifier
    }

    function modifiers(mask, result, remainder) {
      remainder = mask
      result = ""
      if (and(mask, 64)) { result = add_modifier(result, "SUPER"); remainder -= 64 }
      if (and(mask, 4))  { result = add_modifier(result, "CTRL");  remainder -= 4 }
      if (and(mask, 8))  { result = add_modifier(result, "ALT");   remainder -= 8 }
      if (and(mask, 1))  { result = add_modifier(result, "SHIFT"); remainder -= 1 }
      if (remainder != 0) result = add_modifier(result, "MOD" remainder)
      return result
    }

    function normalized_key(key, keycode) {
      if (key == "" && keycode != "0") {
        if (keycode == "43") key = "H"
        else if (keycode == "44") key = "J"
        else if (keycode == "45") key = "K"
        else if (keycode == "46") key = "L"
        else key = "CODE:" keycode
      }
      return toupper(key)
    }

    function append_description(chord, description, token) {
      token = chord SUBSEP description
      if (seen_description[token]) return
      seen_description[token] = 1
      descriptions[chord] = descriptions[chord] == "" \
        ? description \
        : descriptions[chord] " / " description
    }

    function emit_record(modifier, chord, group, action, matched) {
      if (!in_record) return
      in_record = 0

      key = normalized_key(fields["key"], fields["keycode"])
      if (key == "") return

      modifier = modifiers(fields["modmask"] + 0)
      chord = modifier == "" ? key : modifier "+" key
      description = fields["description"]

      matched = match(description, /^\[([^]]+)\][[:space:]]+(.+)$/, metadata)
      if (matched) {
        group = metadata[1]
        action = metadata[2]
      } else {
        group = "Other"
        action = fields["dispatcher"] == "__lua" \
          ? "Lua action (details unavailable)" \
          : fields["dispatcher"] \
            (fields["arg"] == "" ? "" : " " fields["arg"])
      }

      if (!(chord in groups)) groups[chord] = group
      else if (groups[chord] != group) groups[chord] = "Mixed"
      append_description(chord, action)
      records++
    }

    /^bind$/ {
      emit_record()
      delete fields
      in_record = 1
      next
    }

    in_record && match($0, /^\t([a-z]+):[[:space:]]?(.*)$/, field) {
      fields[field[1]] = field[2]
    }

    END {
      emit_record()
      if (records == 0) exit 1
      for (chord in groups) {
        printf "%s\t%s\t%s\n", groups[chord], chord, descriptions[chord]
      }
    }
  ' |
    LC_ALL=C sort -t $'\t' -k1,1 -k2,2 |
    awk -F '\t' '
      $1 != group {
        if (NR > 1) print ""
        group = $1
        print "== " group " =="
      }
      { print $2 "  " $3 }
    '
}

case "${1:-}" in
  "" | --print) ;;
  *) usage ;;
esac

catalog="$($HYPRCTL binds | format_bindings)"
if [[ "${1:-}" == "--print" ]]; then
  printf '%s\n' "$catalog"
  exit 0
fi

printf '%s\n' "$catalog" |
  "$ROFI" -dmenu -i -no-sort -config "$HOME/.config/rofi/config-long.rasi" \
    -mesg 'Read-only keybinding cheatsheet' >/dev/null || true
