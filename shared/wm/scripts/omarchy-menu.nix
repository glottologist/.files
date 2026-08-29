{pkgs}:
pkgs.writeShellScriptBin "omarchy-menu" ''
  set -euo pipefail
  if pidof rofi > /dev/null; then
    pkill rofi
  fi
  rofi="${pkgs.rofi}/bin/rofi"
  menu_rasi="$HOME/.config/rofi/config-menu.rasi"
  pick() {
    local prompt="$1"
    shift
    printf '%s\n' "$@" | $rofi -dmenu -i -p "$prompt" -config "$menu_rasi"
  }

  root=$(pick "Go" \
    "󰀻  Apps" \
    "󰖟  Web apps" \
    "  Capture" \
    "  Style" \
    "󰔛  Reminders" \
    "󱚤  Agents" \
    "  Share" \
    "  System") || exit 0
  [[ -n "$root" ]] || exit 0

  case "$root" in
    *"Web apps")
      app=$(pick "Web" \
        "󰇮  HEY Email" \
        "󰃭  HEY Calendar" \
        "󰚩  ChatGPT" \
        "󰚩  Grok" \
        "  WhatsApp" \
        "  YouTube" \
        "𝕏  X" \
        "󰉏  Google Photos" \
        "󰍒  Google Maps" \
        "  Zoom" \
        "󰒓  Basecamp") || exit 0
      case "$app" in
        *"HEY Email") gtk-launch hey-email ;;
        *"HEY Calendar") gtk-launch hey-calendar ;;
        *ChatGPT) gtk-launch chatgpt-web ;;
        *Grok) gtk-launch grok-web ;;
        *WhatsApp) gtk-launch whatsapp-web ;;
        *YouTube) gtk-launch youtube-web ;;
        *"  X") gtk-launch x-web ;;
        *"Google Photos") gtk-launch google-photos-web ;;
        *"Google Maps") gtk-launch google-maps-web ;;
        *Zoom) gtk-launch zoom-web ;;
        *Basecamp) gtk-launch basecamp-web ;;
      esac
      ;;
    *Apps)
      rofi-launcher
      ;;
    *Capture)
      cap=$(pick "Capture" "  Screenshot" "󰴑  OCR" "  Screen recorder" "󰃉  Colour picker") || exit 0
      case "$cap" in
        *Screenshot) screenshootin ;;
        *OCR) ocr-clip ;;
        *"Screen recorder") gpu-screen-recorder-gtk ;;
        *"Colour picker") hyprpicker -a ;;
      esac
      ;;
    *Style)
      st=$(pick "Style" "  Wallpaper" "󰸌  Aether theme") || exit 0
      case "$st" in
        *Wallpaper) wallsetter ;;
        *"Aether theme") aether ;;
      esac
      ;;
    *Reminders)
      rem=$(pick "Remind" "󰔛  Set" "󰔛  List" "󰔛  Clear") || exit 0
      case "$rem" in
        *Set) desktop-reminder set ;;
        *List) desktop-reminder list ;;
        *Clear) desktop-reminder clear ;;
      esac
      ;;
    *Agents)
      ag=$(pick "Agent" \
        "󱚤  Default agent" \
        "󱚤  Herdr" \
        "󱚤  Claude" \
        "󱚤  Codex" \
        "󱚤  Grok" \
        "󱚤  Crush" \
        "󱚤  OpenCode") || exit 0
      term="''${TERMINAL:-kitty}"
      case "$ag" in
        *"Default agent") $term -e default-agent ;;
        *Herdr) $term -e herdr ;;
        *Claude) $term -e claude ;;
        *Codex) $term -e codex ;;
        *Grok) $term -e grok ;;
        *Crush) $term -e crush ;;
        *OpenCode) $term -e opencode ;;
      esac
      ;;
    *Share)
      localsend
      ;;
    *System)
      sys=$(pick "System" "  Lock" "󰍃  Logout" "  Keybinds") || exit 0
      case "$sys" in
        *Lock) hyprlock ;;
        *Logout) wlogout --css ~/.config/wlogout/main.css ;;
        *Keybinds) list-keybinds ;;
      esac
      ;;
  esac
''
