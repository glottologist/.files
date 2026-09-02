# Nix guideline compliant 2026-09-01
{
  pkgs,
  lib,
  username,
  ...
}:
let
  inherit (import ../../../homes/${username}/variables.nix)
    keyboardLayout
    extraMonitorSettings
    ;

  # Omnixy takes the vendored Omarchy 4 tree as its base; features from the
  # classic and caelestia profiles are adopted one by one on top of it. The
  # decision record lives in agents/ alongside the scaffold notes.
  omarchy = pkgs.omarchy-nixified;

  classicCatalog = import ../hyprland/keybind-catalog.nix { inherit username; };
  catalogToLua = import ../hyprland/catalog-to-lua.nix { inherit lib; };

  # hyprlang "monitor=output,mode,position,scale" lines from variables.nix
  # translated to hl.monitor calls (same translation as the omarchy module).
  monitorLines = builtins.filter (line: lib.hasPrefix "monitor=" line) (
    lib.splitString "\n" extraMonitorSettings
  );
  toLuaMonitor =
    line:
    let
      parts = lib.splitString "," (lib.removePrefix "monitor=" line);
    in
    lib.optionalString (builtins.length parts >= 4) ''
      hl.monitor({
          output   = "${builtins.elemAt parts 0}",
          mode     = "${builtins.elemAt parts 1}",
          position = "${builtins.elemAt parts 2}",
          scale    = ${builtins.elemAt parts 3},
      })
    '';

  # Classic's wallsetter, reshaped for the shell-owned background (decision
  # record: agents/2026-09-01-001, backlog item 7). The shell draws the
  # background itself from the current/background symlink, so rotation is a
  # timer retargeting that symlink through omarchy-theme-bg-set — running
  # wallsetter's awww daemon here would fight the shell's own layer.
  rotateBackground = pkgs.writeShellScript "omnixy-background-rotate" ''
    set -euo pipefail
    dir="$HOME/Pictures/Wallpapers"
    [ -d "$dir" ] || exit 0
    current=$(readlink "$HOME/.local/state/omarchy/current/background" 2>/dev/null || true)
    img=$(find -L "$dir" -maxdepth 1 -type f \
      \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.gif' -o -iname '*.bmp' -o -iname '*.webp' \) \
      | grep -vFx "$current" | shuf -n 1 || true)
    # Plain && would fail the unit under set -e when the only image is
    # already current and the pick comes back empty.
    if [ -n "$img" ]; then
      omarchy-theme-bg-set "$img"
    fi
  '';

  # Classic's idle timings, kept (decision record: agents/2026-09-02-001,
  # backlog item 10). The shell owns the screensaver and the lock screen and
  # runs both far sooner than classic did -- 150s and 300s against classic's
  # 3600s -- so only the numbers are ported, into shell.json below.
  idleTimings = {
    screensaver = 1800;
    lock = 3600;
  };

  # What the shell does not own is display power: nothing in it blanks the
  # monitors on idle, so classic's 3900s dpms listener has no counterpart and
  # the displays would stay lit indefinitely. This is a hypridle carrying that
  # one listener and nothing else -- no lock_cmd, no lock listener -- so it
  # cannot race the shell's own locker for the job.
  dpmsBlank = pkgs.writeShellScript "omnixy-dpms-blank" ''
    # The bar's StayAwake indicator is a file whose existence is the flag
    # (the shell's own probe tests -f and nothing more). hypridle knows
    # nothing about it, so the check belongs here or "stay awake" would
    # still blank the screen.
    [ -e "$HOME/.local/state/omarchy/indicators/stay-awake" ] && exit 0
    hyprctl dispatch dpms off
  '';

  hypridleConfig = pkgs.writeText "omnixy-hypridle.conf" ''
    general {
        ignore_dbus_inhibit = false
    }

    listener {
        timeout = 3900
        on-timeout = ${dpmsBlank}
        on-resume = hyprctl dispatch dpms on
    }
  '';

  # Bar modules replacing the waybar widgets the Omarchy bar lacks (decision
  # record: agents/2026-09-01-001, backlog item 1). systemstats reuses
  # waybar's exec line through the bar's custom command module; pushover and
  # workspaces are custom qml modules installed below.
  systemstatsModule = {
    id = "custom.systemstats";
    exec = ''echo "󰍛 $(free | awk '/Mem:/ {printf "%.0f%%", ($3/$2)*100}') | 󰻠 $(cat /proc/pressure/cpu | awk '/^some/ {print $2}' | cut -d= -f2) | 󰋊 $(df -h / | awk 'NR==2 {print $5}')"'';
    interval = 5;
    tooltip = "Memory used | CPU pressure | root disk used";
    onClick = "omarchy-launch-floating-terminal-with-presentation btop";
  };

  pushoverModule = {
    id = "custom.pushover";
    source = "~/.config/omarchy/bar/modules/Pushover.qml";
  };

  # Upstream's omarchy.workspaces stops at five; this one follows the
  # twenty-two the classic keybindings reach.
  workspacesModule = {
    id = "custom.workspaces";
    source = "~/.config/omarchy/bar/modules/Workspaces.qml";
  };

  # The classic waybar split, module for module: the top bar carries the tray
  # and the system readouts, the bottom bar the launcher, workspaces, window
  # title and status cluster. `bar.bottom` is the omnixy.bar plugin's own key
  # -- the stock bar ignores it, so a shell.json carrying it stays valid.
  barLayout = {
    id = "omnixy.bar";
    position = "top";
    centerAnchor = "";
    layout = {
      left = [ { id = "omarchy.tray"; } ];
      center = [
        systemstatsModule
        # Classic's custom/codexbar; the omarchy widget covers the same
        # per-model AI usage and more.
        { id = "omarchy.agents"; }
      ];
      right = [
        { id = "omarchy.keyboard-layout"; }
        { id = "omarchy.weather"; }
        { id = "omarchy.monitor"; }
        { id = "omarchy.network"; }
        { id = "omarchy.audio"; }
        { id = "omarchy.microphone"; }
      ];
    };
    bottom = {
      position = "bottom";
      centerAnchor = "omarchy.active-window";
      layout = {
        left = [
          { id = "omarchy.menu"; }
          workspacesModule
        ];
        center = [ { id = "omarchy.active-window"; } ];
        right = [
          pushoverModule
          # Classic's custom/notification lives here as the shell's own
          # indicator strip, do-not-disturb included.
          { id = "omarchy.indicators"; }
          { id = "omarchy.system-update"; }
          { id = "omarchy.bluetooth"; }
          # Classic's battery module.
          { id = "omarchy.power"; }
          {
            id = "omarchy.clock";
            format = "dddd HH:mm";
            formatAlt = "d MMMM 'W'ww yyyy";
          }
        ];
      };
    };
  };
in
{
  # Theme state seeding and the writable ~/.config/omarchy directories come
  # from the omarchy module, which is always imported alongside this one;
  # both sessions share ~/.local/state/omarchy until omnixy grows its own
  # theming decisions.
  xdg.configFile = {
    # Session entry point; the greeter wrapper passes
    # --config ~/.config/hypr/omnixy.lua and exports OMARCHY_PATH.
    "hypr/omnixy.lua".text = ''
      -- Generated by shared/wm/omnixy/default.nix. Follows upstream's
      -- config/hypr/hyprland.lua template, with classic keybindings
      -- replacing the omarchy defaults.
      dofile((os.getenv("OMARCHY_PATH") or "${omarchy}") .. "/default/hypr/bootstrap.lua")

      omarchy_default_bindings = false

      require("default.hypr.omarchy")

      require("omnixy-cfg.monitors")
      require("omnixy-cfg.input")
      require("omnixy-cfg.env")
      require("omnixy-cfg.rules")
      require("omnixy-cfg.bindings")
      require("omnixy-cfg.session")

      -- Toggle config flags dynamically, as upstream's template does.
      require("default.hypr.toggles")
    '';

    "omnixy-cfg/monitors.lua".text = ''
      ${lib.concatStrings (map toLuaMonitor monitorLines)}
    '';

    "omnixy-cfg/input.lua".text = ''
      -- default/hypr/input.lua reads the layout from vconsole and falls
      -- back to "us"; override with the configured layout.
      hl.config({
          input = {
              kb_layout = "${keyboardLayout}",
          },
      })
    '';

    # Environment (decision record: agents/2026-09-02-001, backlog item 13).
    # default/hypr/envs.lua already covers the Wayland handoff -- GDK_BACKEND,
    # QT_QPA_PLATFORM, MOZ_ENABLE_WAYLAND, the XDG_* trio -- so only what is
    # specific to this system, or to a deliberate classic choice, is added.
    # Deliberately not ported: classic's EDITOR, which omarchy owns through
    # omarchy-default-editor, and its GDK_SCALE/QT_SCALE_FACTOR pins, which
    # are no-ops at the scale this host runs.
    "omnixy-cfg/env.lua".text = ''
      -- Loaded after default.hypr.omarchy, so these win where they overlap.

      -- The nixpkgs Electron wrapper reads this, not upstream's
      -- ELECTRON_OZONE_PLATFORM_HINT; without it every Electron app on the
      -- system falls back to XWayland.
      hl.env("NIXOS_OZONE_WL", "1")
      hl.env("NIXPKGS_ALLOW_UNFREE", "1")

      -- Qt draws its own titlebars otherwise, which the tiling layout has no
      -- use for.
      hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")

      -- A deliberate classic choice: SDL titles are steadier under XWayland
      -- than on native Wayland.
      hl.env("SDL_VIDEODRIVER", "x11")
      hl.env("CLUTTER_BACKEND", "wayland")
    '';

    # Window rules (decision record: agents/2026-09-02-001, backlog item 12).
    # Upstream's default/hypr/apps covers the applications it ships with, so
    # this carries only the two things classic does that it does not.
    "omnixy-cfg/rules.lua".text = ''
      -- Loaded after default.hypr.omarchy, so these append to its rules.

      -- Omarchy inhibits idle only for named applications -- retroarch,
      -- steam, moonlight, geforce -- while classic inhibits it for anything
      -- fullscreen. Without this a fullscreen video in a browser still lets
      -- the screensaver take the screen.
      o.window(".*", { idle_inhibit = "fullscreen" })

      -- Settings and control-panel windows classic floats and upstream's
      -- system.lua does not mention.
      o.window(
        "^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol|nwg-look|qt5ct|qt6ct|nm-connection-editor|blueman-manager|.blueman-manager-wrapped|file-roller|org.gnome.FileRoller|gnome-disks|nwg-displays)$",
        { tag = "+floating-window" }
      )
    '';

    "omnixy-cfg/bindings.lua".source = ./bindings.lua;

    "omnixy-cfg/session.lua".text = ''
      -- The session wrapper starts Hyprland bare, without uwsm, so nothing
      -- raises graphical-session.target and user services gated on it (the
      -- pushover-bridge among them) would never start. graphical-session.target
      -- refuses manual starts, and hyprland-session.target would drag in the
      -- classic stack (waybar, dunst, hypridle) that the shell replaces, so
      -- the session starts its own BindsTo wrapper target instead.
      --
      -- default/hypr/autostart.lua already imports the whole environment into
      -- the user manager and dbus on hyprland.start, and omarchy.lua requires
      -- it before this file is reached, so the variables session services
      -- need are on their way. Both calls are fire-and-forget, though, so a
      -- service starting here can still beat the import; units that need
      -- WAYLAND_DISPLAY have to tolerate arriving early rather than assume it.
      hl.on("hyprland.start", function()
          hl.exec_cmd("systemctl --user start omnixy-session.target")
      end)
    '';

    "omarchy/bar/modules/Pushover.qml".source = ./Pushover.qml;
    "omarchy/bar/modules/Workspaces.qml".source = ./Workspaces.qml;

    # A bar option, selected by bar.id in shell.json. The shell discovers it
    # by scanning ~/.config/omarchy/plugins for manifests, and only reads
    # from there, so store symlinks are enough.
    "omarchy/plugins/omnixy-bar/manifest.json".source = ./bar/manifest.json;
    "omarchy/plugins/omnixy-bar/Bar.qml".source = ./bar/Bar.qml;

    "omnixy-cfg/classic-binds.lua".text = catalogToLua classicCatalog;
  };

  systemd.user = {
    # Startable stand-in for graphical-session.target (which refuses manual
    # starts). Deliberately not hyprland-session.target: that would pull in
    # waybar, dunst and hypridle, whose jobs the quickshell shell owns here.
    targets.omnixy-session.Unit = {
      Description = "Omnixy quickshell session";
      BindsTo = [ "graphical-session.target" ];
      Wants = [ "graphical-session-pre.target" ];
      After = [ "graphical-session-pre.target" ];
    };

    # Wallsetter's cadence (a random wallpaper every two minutes), scoped to
    # the omnixy session by the target. omarchy-theme-bg-set needs the
    # omarchy bin and runtime tools for its omarchy-shell IPC call; the
    # shell's symlink poll covers the case where IPC misses.
    services.omnixy-background-rotate = {
      Unit = {
        Description = "Rotate the Omnixy background from ~/Pictures/Wallpapers";
        PartOf = [ "omnixy-session.target" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${rotateBackground}";
        Environment = [
          "PATH=${omarchy}/bin:${omarchy.runtimePath}:${
            lib.makeBinPath [
              pkgs.bash
              pkgs.coreutils
              pkgs.findutils
              pkgs.gnugrep
            ]
          }"
        ];
      };
    };

    services.omnixy-dpms = {
      Unit = {
        Description = "Blank the displays on idle for the Omnixy session";
        PartOf = [ "omnixy-session.target" ];
        After = [ "omnixy-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.hypridle}/bin/hypridle -c ${hypridleConfig}";
        # Deliberately not ConditionEnvironment=WAYLAND_DISPLAY, which classic's
        # unit carries: the environment import in default/hypr/autostart.lua and
        # the target start in session.lua are both fire-and-forget, so this can
        # be reached first. A Condition would then skip the unit silently for
        # the whole session, where a restart simply picks the variable up on the
        # next attempt.
        Restart = "on-failure";
        RestartSec = 10;
        # hyprctl reaches the compositor through
        # HYPRLAND_INSTANCE_SIGNATURE, which session.lua imports before this
        # unit's target comes up; the binary itself has to be named here,
        # since the user manager does not inherit the session PATH.
        Environment = [ "PATH=${lib.makeBinPath [ pkgs.hyprland pkgs.coreutils ]}" ];
      };
      Install.WantedBy = [ "omnixy-session.target" ];
    };

    timers.omnixy-background-rotate = {
      Unit = {
        Description = "Timer for the Omnixy background rotation";
        PartOf = [ "omnixy-session.target" ];
      };
      Timer = {
        OnActiveSec = "5s";
        OnUnitActiveSec = "2min";
      };
      Install.WantedBy = [ "omnixy-session.target" ];
    };
  };

  # Install the split-bar layout into shell.json. The shell treats the user
  # file as canonical once it exists (no deep-merge) and rewrites it whenever
  # a bar gesture lands, so it cannot be a store symlink -- hence an
  # activation script rather than xdg.configFile.
  #
  # The write is gated on `bar.bottom` being absent, which makes it a one-time
  # migration: a fresh install gets the layout on top of upstream's defaults,
  # the single-bar file the earlier Omnixy scaffold seeded gets converted, and
  # every later drag-to-reorder survives untouched. Only the four bar keys the
  # split needs are written; the rest of shell.json is left alone.
  #
  # Note that shell.json is shared with the Omarchy session, which reads the
  # same ~/.config/omarchy: selecting the omnixy.bar plugin here splits that
  # session's bar too. Separating them would mean patching the hard-coded
  # config path throughout the vendored tree.
  home.activation.omnixyBarLayout = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    cfg="$HOME/.config/omarchy/shell.json"
    jq=${pkgs.jq}/bin/jq
    apply='.bar.id = $bar.id
      | .bar.position = $bar.position
      | .bar.centerAnchor = $bar.centerAnchor
      | .bar.layout = $bar.layout
      | .bar.bottom = $bar.bottom
      | .idle = $idle'
    args=(--argjson bar ${lib.escapeShellArg (builtins.toJSON barLayout)}
          --argjson idle ${lib.escapeShellArg (builtins.toJSON idleTimings)})

    mkdir -p "$HOME/.config/omarchy"
    if [ ! -e "$cfg" ]; then
      "$jq" "''${args[@]}" "$apply" "${omarchy}/config/omarchy/shell.json" >"$cfg"
    elif ! "$jq" -e 'has("bar") and (.bar | has("bottom"))' "$cfg" >/dev/null; then
      "$jq" "''${args[@]}" "$apply" "$cfg" >"$cfg.omnixy" && mv "$cfg.omnixy" "$cfg"
    fi
  '';
}
