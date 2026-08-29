{pkgs}:
pkgs.writeShellScriptBin "default-agent" ''
  set -euo pipefail
  conf="''${XDG_CONFIG_HOME:-$HOME/.config}/desktop-agent/name"
  action="''${1:-run}"

  case "$action" in
    set)
      name="''${2:-}"
      [[ -n "$name" ]] || {
        echo "usage: default-agent set <claude|codex|grok|crush|opencode|pi>" >&2
        exit 2
      }
      mkdir -p "$(dirname "$conf")"
      printf '%s\n' "$name" >"$conf"
      echo "default agent: $name"
      ;;
    show)
      cat "$conf" 2>/dev/null || echo claude
      ;;
    run)
      name="$(cat "$conf" 2>/dev/null || echo claude)"
      exec "$name"
      ;;
    *)
      echo "usage: default-agent [run|show|set <name>]" >&2
      exit 2
      ;;
  esac
''
