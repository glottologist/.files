{pkgs}:
pkgs.writeShellScriptBin "list-keybinds" ''
  if pidof rofi > /dev/null; then
    pkill rofi
  fi

  sheet=$(cat <<'EOF'
== Launch ==
SUPER+Return          Terminal
SUPER+SPACE           Action menu
SUPER+D               App launcher
SUPER+W               Browser
SUPER+E               Emoji picker
SUPER+SHIFT+A         ChatGPT web app
SUPER+SHIFT+ALT+A     Grok web app
SUPER+SHIFT+E         HEY Email
SUPER+SHIFT+CTRL+A    Default agent

== Clipboard ==
SUPER+C               Copy
SUPER+X               Cut (GUI only)
SUPER+V               Paste
SUPER+CTRL+V          Clipboard history
SUPER+ALT+C           Colour picker

== Capture ==
SUPER+S               Screenshot
SUPER+SHIFT+V         Screen recorder
SUPER+CTRL+Print      OCR region to clipboard

== Reminders ==
SUPER+CTRL+R          Set reminder
SUPER+CTRL+ALT+R      List reminders
SUPER+CTRL+SHIFT+R    Clear reminders

== Agents ==
SUPER+CTRL+Return     Herdr

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
