{pkgs}:
pkgs.writeShellScriptBin "list-keybinds" ''
  if pidof rofi > /dev/null; then
    pkill rofi
  fi

  sheet=$(cat <<'EOF'
== Launch ==
SUPER+Return          Terminal
SUPER+D               App launcher
SUPER+W               Browser
SUPER+E               Emoji picker

== Clipboard ==
SUPER+C               Copy
SUPER+X               Cut (GUI only)
SUPER+V               Paste
SUPER+CTRL+V          Clipboard history
SUPER+ALT+C           Colour picker

== Capture ==
SUPER+S               Screenshot
SUPER+SHIFT+V         Screen recorder

== Session ==
SUPER+SHIFT+L         Lock
SUPER+SHIFT+Q         Logout menu
SUPER+SHIFT+C         Exit Hyprland

== Windows ==
SUPER+Q               Close window
SUPER+F               Fullscreen
SUPER+H/J/K/L         Move focus
EOF
)

  raw=$(grep -E '^bind' ~/.config/hypr/hyprland.conf 2>/dev/null | sed 's/\$modifier/SUPER/g' || true)
  printf '%s\n\n== Raw binds ==\n%s\n' "$sheet" "$raw" \
    | rofi -dmenu -i -config ~/.config/rofi/config-long.rasi \
        -mesg 'Enter does nothing; this is a cheatsheet'
''
