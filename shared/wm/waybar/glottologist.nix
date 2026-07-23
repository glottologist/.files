{
  pkgs,
  config,
  lib,
  ...
}: let
  terminal = "ghostty";
  base00 = "eff1f5"; # Base - main background (light)
  base01 = "e6e9ef"; # Mantle - lighter background
  base02 = "dce0e8"; # Crust - selection background
  base03 = "bcc0cc"; # Surface1 - comments, invisibles
  base04 = "acb0be"; # Surface2 - dark foreground
  base05 = "4c4f69"; # Text - default foreground (dark)
  base06 = "5c5f77"; # Subtext1 - light foreground
  base07 = "6c6f85"; # Subtext0 - lightest foreground
  base08 = "d20f39"; # Red - variables, markup
  base09 = "fe640b"; # Peach - integers, constants
  base0A = "df8e1d"; # Yellow - classes, search
  base0B = "40a02b"; # Green - strings, additions
  base0C = "179299"; # Teal - support, regex
  base0D = "1e66f5"; # Blue - functions, methods
  base0E = "8839ef"; # Mauve - keywords, storage
  base0F = "dc8a78"; # Rosewater - deprecated, tags

  codexbar = pkgs.callPackage ./codexbar-cli.nix {};
  codexbar-waybar = pkgs.callPackage ./codexbar-waybar.nix {inherit codexbar;};

  # Only the providers we care about. Skip gemini: codexbar 0.43.0 SIGILLs
  # in GeminiStatusProbe on this host.
  codexbarProviders = "codex claude grok";
  codexbarEnv = "CODEXBAR_PROVIDERS='${codexbarProviders}'";

  # Compact bar text: weekly (secondary) used% for each agent. Grok has no
  # secondary window — fall back to primary. Tooltip stays full detail via
  # the upstream codexbar-waybar aggregator.
  #
  # fetch() must NOT append `[]` when codexbar exits non-zero but still
  # printed valid JSON (e.g. Claude OAuth expired). That used to produce
  # `[{...}]\n[]`, which breaks jq --argjson and hides the whole module.
  #
  # Anthropic rate-limits the Claude usage endpoint under frequent polling.
  # We cache last-good per-provider JSON and reuse it on transient errors
  # (rate limit / timeout) so the bar does not flip to ⚠ after a successful
  # `claude login`. Hard auth errors still surface as ⚠.
  codexbarWeekly = pkgs.writeShellScript "codexbar-weekly-waybar" ''
    set -euo pipefail
    export PATH="${lib.makeBinPath [pkgs.jq pkgs.coreutils pkgs.gnugrep]}:$PATH"
    export CODEXBAR_BIN="${codexbar}/bin/codexbar"
    export CODEXBAR_PROVIDERS="${codexbarProviders}"

    CB="${codexbar}/bin/codexbar"
    timeout_s=25
    cache_dir="''${XDG_CACHE_HOME:-$HOME/.cache}/codexbar-waybar"
    mkdir -p "$cache_dir"

    is_transient_error() {
      local msg
      msg=$(printf '%s' "$1" | jq -r '.[0].error.message // empty' 2>/dev/null || true)
      case "$msg" in
        *rate\ limited*|*Rate\ limited*|*try\ again*|*timeout*|*Timeout*|*temporar*) return 0 ;;
        *) return 1 ;;
      esac
    }

    has_usage() {
      printf '%s' "$1" | jq -e '.[0].usage != null and .[0].error == null' >/dev/null 2>&1
    }

    fetch() {
      local provider="$1"
      shift
      local cache_file="$cache_dir/$provider.json"
      local out

      out=$(timeout "$timeout_s" "$CB" usage --provider "$provider" --format json --no-color "$@" 2>/dev/null || true)

      if [ -n "$out" ] && has_usage "$out"; then
        printf '%s\n' "$out" >"$cache_file"
        printf '%s\n' "$out"
        return 0
      fi

      # Transient failure (rate limit / empty) — prefer last good sample.
      if [ -f "$cache_file" ] && has_usage "$(cat "$cache_file")"; then
        if [ -z "$out" ] || is_transient_error "$out"; then
          cat "$cache_file"
          return 0
        fi
      fi

      if [ -n "$out" ] && printf '%s' "$out" | jq -e . >/dev/null 2>&1; then
        printf '%s\n' "$out"
      else
        echo '[]'
      fi
    }

    codex_json=$(fetch codex --source oauth)

    # Claude OAuth tokens expire and codexbar cannot refresh them; the cli
    # source reads Claude Code's local data and keeps working regardless.
    # Mirrors upstream codexbar-waybar's FALLBACK_SOURCES[claude]=cli.
    claude_json=$(fetch claude --source oauth)
    if ! has_usage "$claude_json"; then
      claude_json=$(fetch claude --source cli)
    fi

    grok_json=$(fetch grok)

    jq -nc \
      --argjson codex "$codex_json" \
      --argjson claude "$claude_json" \
      --argjson grok "$grok_json" \
      '
      def weekly(entry):
        if entry == null or entry.error then null
        elif entry.usage.secondary.usedPercent != null then (entry.usage.secondary.usedPercent | floor)
        elif entry.usage.primary.usedPercent != null then (entry.usage.primary.usedPercent | floor)
        else null end;

      def fmt(entry; name; pct):
        if entry != null and entry.error then "\(name):⚠"
        elif pct == null then "\(name):—"
        else "\(name):\(pct)%" end;

      def first_entry(arr):
        if (arr | type) == "array" and (arr | length) > 0 then arr[0] else null end;

      (first_entry($codex)) as $c
      | (first_entry($claude)) as $a
      | (first_entry($grok)) as $g
      | (weekly($c)) as $cw
      | (weekly($a)) as $aw
      | (weekly($g)) as $gw
      | ([$cw, $aw, $gw] | map(select(. != null)) | (max // 0)) as $max
      | ([$c, $a, $g] | all(. == null or .error)) as $all_err
      | {
          text: ("🤖 " + ([
            fmt($c; "Codex"; $cw),
            fmt($a; "Claude"; $aw),
            fmt($g; "Grok"; $gw)
          ] | join(" · "))),
          tooltip: (
            [
              (if $c == null then empty
               elif $c.error then "Codex: \($c.error.message)"
               else
                 "Codex weekly: \($cw // "—")%"
                 + (if $c.usage.secondary.resetDescription then " — resets \($c.usage.secondary.resetDescription)" else "" end)
                 + (if $c.usage.primary.usedPercent != null then "\nCodex session: \($c.usage.primary.usedPercent | floor)%" else "" end)
               end),
              (if $a == null then empty
               elif $a.error then "Claude: \($a.error.message)"
               else
                 "Claude weekly: \($aw // "—")%"
                 + (if $a.usage.secondary.resetDescription then " — resets \($a.usage.secondary.resetDescription)" else "" end)
                 + (if $a.usage.primary.usedPercent != null then "\nClaude session: \($a.usage.primary.usedPercent | floor)%" else "" end)
               end),
              (if $g == null then empty
               elif $g.error then "Grok: \($g.error.message)"
               else
                 "Grok: \($gw // "—")%"
                 + (if $g.usage.primary.resetDescription then " — resets \($g.usage.primary.resetDescription)"
                    elif $g.usage.secondary.resetDescription then " — resets \($g.usage.secondary.resetDescription)"
                    else "" end)
               end)
            ] | join("\n")
          ),
          class: (if $all_err then "stale"
                  elif $max >= 90 then "critical"
                  elif $max >= 70 then "warning"
                  else "ok" end),
          percentage: $max
        }
      '
  '';

  pushoverPaths = import ../../alerts/paths.nix;

  # The pushover-bridge daemon owns this counter; waybar only reads it, and
  # clears it on click. A missing file simply means nothing has arrived yet.
  pushoverStatus = pkgs.writeShellScript "pushover-waybar" ''
    set -euo pipefail
    state="${pushoverPaths.stateFileShell}"
    count=$(cat "$state" 2>/dev/null || echo 0)
    [ "$count" -gt 0 ] 2>/dev/null || count=0
    if [ "$count" -gt 0 ]; then
      ${pkgs.jq}/bin/jq -cn --arg c "$count" \
        '{text: $c, alt: "unread", tooltip: ("\($c) unread Pushover alert(s)"), class: "unread"}'
    else
      ${pkgs.jq}/bin/jq -cn \
        '{text: "", alt: "none", tooltip: "No unread Pushover alerts", class: "none"}'
    fi
  '';

  pushoverClear = pkgs.writeShellScript "pushover-waybar-clear" ''
    set -euo pipefail
    state="${pushoverPaths.stateFileShell}"
    mkdir -p "$(dirname "$state")"
    printf '0\n' >"$state"
    ${pkgs.procps}/bin/pkill -RTMIN+${toString pushoverPaths.waybarSignal} waybar || true
  '';

  # Shared module definitions for both bars.
  modules = {
    "hyprland/workspaces" = {
      format = "{name}";
      format-icons = {
        default = "";
        active = "";
        urgent = "";
      };
      tooltip = true;
      tooltip-format = "Workspace {name}";
      on-scroll-up = "hyprctl dispatch workspace e+1";
      on-scroll-down = "hyprctl dispatch workspace e-1";
    };
    "clock" = {
      format = '' {:%H:%M}'';
      tooltip = true;
      tooltip-format = "<big>{:%A, %d %B %Y }</big><tt><small>{calendar}</small></tt>";
    };
    "hyprland/window" = {
      max-length = 60;
      separate-outputs = false;
    };
    "memory" = {
      interval = 5;
      format = " {}%";
      tooltip = true;
      on-click = "${terminal} -e btop";
    };
    "cpu" = {
      interval = 5;
      format = " {usage:2}%";
      tooltip = true;
      on-click = "${terminal} -e btop";
    };
    "disk" = {
      format = " {free}";
      tooltip = true;
      on-click = "${terminal} -e ncdu";
    };
    "network" = {
      format-icons = ["󰤯" "󰤟" "󰤢" "󰤥" "󰤨"];
      format-ethernet = "󰈀 {bandwidthDownBits}";
      format-wifi = "{icon} {bandwidthDownBits}";
      format-disconnected = "󰤮";
      tooltip = false;
      on-click = "${terminal} -e speedtest";
    };
    "custom/systemstats" = {
      format = "{}";
      interval = 5;
      exec = "echo \"󰍛 $(free | awk '/Mem:/ {printf \"%.0f%%\", ($3/$2)*100}') | 󰻠 $(cat /proc/pressure/cpu | awk '/^some/ {print $2}'| cut -d= -f2) | 󰋊 $(df -h / | awk 'NR==2 {print $5}')\"";
      tooltip = true;
      on-click = "${terminal} -e btop & ${terminal} -e ncdu";
    };
    # CodexBar AI usage — weekly % for Codex / Claude / Grok on the bar
    "custom/codexbar" = {
      exec = "${codexbarWeekly}";
      return-type = "json";
      format = "{}";
      # 30s hammered Anthropic's usage endpoint and produced false ⚠ after login.
      interval = 120;
      signal = 8;
      on-click = "env ${codexbarEnv} ${codexbar-waybar}/bin/codexbar-popup";
      on-click-right = "bash -c 'notify-send -a CodexBar -t 8000 \"AI usage\" \"$(${codexbarWeekly} | ${pkgs.jq}/bin/jq -r .tooltip)\"'";
      tooltip = true;
    };
    "tray" = {
      spacing = 12;
    };
    "pulseaudio" = {
      format = "{icon} {volume}% {format_source}";
      format-bluetooth = "{volume}% {icon} {format_source}";
      format-bluetooth-muted = "󰂲 {icon} {format_source}";
      format-muted = "󰝟 {format_source}";
      format-source = "󰍬 {volume}%";
      format-source-muted = "󰍭";
      format-icons = {
        headphone = "󰋋";
        hands-free = "󰋎";
        headset = "󰋎";
        phone = "󰄜";
        portable = "󰦧";
        car = "󰄋";
        default = ["󰕿" "󰖀" "󰕾"];
      };
      on-click = "pavucontrol";
    };
    "custom/exit" = {
      tooltip = false;
      format = "⏻";
      on-click = "sleep 0.1 && wlogout --css ~/.config/wlogout/main.css";
    };
    "custom/startmenu" = {
      tooltip = false;
      format = " ";
      on-click = "rofi -show drun";
    };
    "idle_inhibitor" = {
      format = "{icon}";
      format-icons = {
        activated = " ";
        deactivated = " ";
      };
      tooltip = "true";
    };
    "custom/notification" = {
      tooltip = false;
      format = "{icon} {}";
      format-icons = {
        notification = "<span foreground='red'><sup></sup></span>";
        none = "";
        dnd-notification = "<span foreground='red'><sup></sup></span>";
        dnd-none = "";
        inhibited-notification = "<span foreground='red'><sup></sup></span>";
        inhibited-none = "";
        dnd-inhibited-notification = "<span foreground='red'><sup></sup></span>";
        dnd-inhibited-none = "";
      };
      return-type = "json";
      exec-if = "which swaync-client";
      exec = "swaync-client -swb";
      on-click = "swaync-client -t";
      escape = true;
    };
    # Fed by the pushover-bridge daemon. The signal makes the count appear the
    # moment a message lands rather than at the end of the polling interval;
    # the interval is only a backstop for a missed signal.
    "custom/pushover" = {
      exec = "${pushoverStatus}";
      return-type = "json";
      format = "{icon} {}";
      format-icons = {
        unread = "<span foreground='red'><sup></sup></span>";
        none = "";
      };
      interval = 60;
      signal = pushoverPaths.waybarSignal;
      on-click = "${pushoverClear}";
      tooltip = true;
    };
    "battery" = {
      states = {
        warning = 30;
        critical = 15;
      };
      format = "{icon} {capacity}%";
      format-charging = "󰂄 {capacity}%";
      format-plugged = "󱘖 {capacity}%";
      format-icons = ["󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
      on-click = "";
      tooltip = false;
    };
  };

  topBar =
    {
      name = "top";
      layer = "top";
      position = "top";
      # Tray top-left; systemstats + codexbar centered; network + audio top-right.
      modules-left = ["tray"];
      modules-center = ["custom/systemstats" "custom/codexbar"];
      modules-right = ["network" "pulseaudio"];
    }
    // modules;

  bottomBar =
    {
      name = "bottom";
      layer = "top";
      position = "bottom";
      # Apps (startmenu) bottom-left. Power (battery) sits next to the clock.
      modules-left = ["custom/startmenu" "hyprland/workspaces"];
      modules-center = ["hyprland/window"];
      modules-right = ["custom/pushover" "custom/notification" "battery" "clock" "custom/exit"];
    }
    // modules;
in
  with lib; {
    home.packages = with pkgs; [
      libappindicator-gtk3
      libappindicator
      # codexbar-waybar stack (CLI + waybar module + GTK4 popover)
      codexbar
      codexbar-waybar
      jq
      libnotify # right-click usage summary via notify-send
    ];

    # Provider brand icons for the GTK4 popover tabs/settings rows.
    xdg.dataFile."codexbar-waybar/icons".source = "${codexbar-waybar}/share/codexbar-waybar/icons";

    # Configure & Theme Waybar
    programs.waybar = {
      enable = true;
      package = pkgs.waybar;
      settings = [topBar bottomBar];
      style = concatStrings [
        ''
                * {
                  font-size: 14px;
                  font-family: "JetBrainsMono Nerd Font", "JetBrainsMono NF", "Font Awesome 6 Free", sans-serif;
                  font-weight: bold;
                }
                window#waybar {
                  background-color: rgba(26,27,38,0);
                  border-bottom: 1px solid rgba(26,27,38,0);
                  border-radius: 0px;
                  color: #${base0F};
                }
                #workspaces {
                  background: linear-gradient(45deg, #${base01}, #${base01});
                  margin: 2px;
                  padding: 0px 1px;
                  border-radius: 15px;
                  border: 0px;
                  font-style: normal;
                  color: #${base00};
                }
                #workspaces button {
                  padding: 0px 5px;
                  margin: 4px 3px;
                  border-radius: 15px;
                  border: 0px;
                  color: #${base00};
                  background: linear-gradient(45deg, #${base0D}, #${base0E});
                  opacity: 0.5;
                  transition: all 0.3s ease-in-out;
                }
                #workspaces button.active {
                  padding: 0px 5px;
                  margin: 4px 3px;
                  border-radius: 15px;
                  border: 0px;
                  color: #${base00};
                  background: linear-gradient(45deg, #${base0D}, #${base0E});
                  opacity: 1.0;
                  min-width: 40px;
                  transition: all 0.3s ease-in-out;
                }
                #workspaces button:hover {
                  border-radius: 15px;
                  color: #${base00};
                  background: linear-gradient(45deg, #${base0D}, #${base0E});
                  opacity: 0.8;
                }
                tooltip {
                  background: #${base00};
                  border: 1px solid #${base0E};
                  border-radius: 10px;
                }
                tooltip label {
                  color: #${base07};
                }
                #window {
                  margin: 2px;
                  padding: 2px 20px;
                  color: #${base05};
                  background: #${base01};
                  border-radius: 15px 15px 15px 15px;
                }
                #memory {
                  color: #${base0F};
                  background: #${base01};
                  margin: 2px;
                  padding: 2px 20px;
                  border-radius: 15px 15px 15px 15px;
                }
                #clock {
                  color: #${base0B};
                  background: #${base00};
                  border-radius: 15px 15px 15px 15px;
                  margin: 2px;
                  padding: 2px 20px;
                }
                #idle_inhibitor {
                  color: #${base09};
                  background: #${base00};
                  border-radius: 15px 15px 15px 15px;
                  margin: 2px;
                  padding: 2px 20px;
                }
                #cpu {
                  color: #${base07};
                  background: #${base00};
                  border-radius: 15px 15px 15px 15px;
                  margin: 2px;
                  padding: 2px 20px;
                }
                #custom-systemstats {
                  color: #${base0C};
                  background: #${base00};
                  border-radius: 15px 15px 15px 15px;
                  margin: 2px;
                  padding: 2px 20px;
                }
                #disk {
                  color: #${base0F};
                  background: #${base00};
                  border-radius: 15px 15px 15px 15px;
                  margin: 2px;
                  padding: 2px 20px;
                }
                #battery {
                  color: #${base08};
                  background: #${base00};
                  border-radius: 15px 15px 15px 15px;
                  margin: 2px;
                  padding: 2px 20px;
                }
                #network {
                  color: #${base09};
                  background: #${base00};
                  border-radius: 15px 15px 15px 15px;
                  margin: 2px;
                  padding: 2px 20px;
                }
                #tray {
                  color: #${base05};
                  background: #${base00};
                  border-radius: 15px 15px 15px 15px;
                  margin: 2px;
                  padding: 2px 15px;
                }
                #pulseaudio {
                  color: #${base0D};
                  background: #${base01};
                  margin: 2px;
                  padding: 2px 20px;
                  border-radius: 15px 15px 15px 15px;
                }
                #custom-notification {
                  color: #${base0C};
                  background: #${base00};
                  border-radius: 15px 15px 15px 15px;
                  margin: 2px;
                  padding: 2px 20px;
                }
                #custom-startmenu {
                  color: #${base0E};
                  background: #${base00};
                  border-radius: 0px 15px 15px 0px;
                  margin: 2px 2px 2px 0px;
                  padding: 2px 20px;
                  font-size: 20px;
                }
                #custom-exit {
                  color: #${base0E};
                  background: #${base00};
                  border-radius: 15px 0px 0px 15px;
                  margin: 2px 0px 2px 2px;
                  padding: 2px 20px;
                }
                #custom-codexbar {
                  color: #${base0C};
                  background: #${base00};
                  border-radius: 15px 15px 15px 15px;
                  margin: 2px;
                  padding: 2px 14px;
                  font-weight: bold;
                }
                #custom-codexbar.ok {
                  color: #${base0B};
                }
                /* Opaque solid tints (waybar CSS has no alpha/color-mix). */
                #custom-codexbar.warning {
                  color: #${base0A};
                  background: #ebdbc5;
                }
                #custom-codexbar.critical {
                  color: #${base08};
                  background: #e9bfcc;
                  animation: codexbar-pulse 2s ease-in-out infinite alternate;
                }
                #custom-codexbar.stale {
                  color: #${base04};
                }
                @keyframes codexbar-pulse {
                  from { background: #e9bfcc; }
                  to   { background: #e397aa; }
                }
        ''
      ];
    };
  }
