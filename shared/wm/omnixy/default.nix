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

  # Omnixy takes the vendored upstream tree (desktop/) as its base; features from the
  # classic and caelestia profiles are adopted one by one on top of it. The
  # decision record lives in agents/ alongside the scaffold notes.
  shell = pkgs.omnixy-desktop;

  classicCatalog = import ../hyprland/keybind-catalog.nix { inherit username; };
  catalogToLua = import ../hyprland/catalog-to-lua.nix { inherit lib; };

  # hyprlang "monitor=output,mode,position,scale" lines from variables.nix
  # translated to hl.monitor calls.
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

  # The rotating wallpaper sets: one directory per set under
  # secrets/wallpapers. Classic links only the single set named in
  # variables.nix, to ~/Pictures/Wallpapers, and rotation ran over that alone;
  # the background picker below reaches every set, so all of them are linked
  # into the home directory. "common" is not a set -- it carries the login
  # face and the stylix source image.
  wallpaperRoot = ../../../secrets/wallpapers;

  wallpaperSets = builtins.attrNames (
    lib.filterAttrs (name: type: type == "directory" && name != "common") (
      builtins.readDir wallpaperRoot
    )
  );

  # Non-recursive: Home Manager gives each set a store path of its own and
  # the home directory a single symlink to it, rather than the per-file link
  # farm the recursive form builds. natgeo lands on the same path classic's
  # ~/Pictures/Wallpapers already uses, so only the other sets are added.
  wallpaperSetLinks = lib.listToAttrs (
    map (
      set:
      lib.nameValuePair "Pictures/WallpaperSets/${set}" {
        source = wallpaperRoot + "/${set}";
      }
    ) wallpaperSets
  );

  setLabel =
    set:
    lib.toUpper (builtins.substring 0 1 set) + builtins.substring 1 (builtins.stringLength set) set;

  # Classic's wallsetter, reshaped for the shell-owned background (decision
  # record: agents/2026-09-01-001, backlog item 7). The shell draws the
  # background itself from the current/background symlink, so rotation is a
  # timer retargeting that symlink through omnixy-theme-bg-set — running
  # wallsetter's awww daemon here would fight the shell's own layer.
  rotateBackground = pkgs.writeShellScript "omnixy-background-rotate" ''
    set -euo pipefail
    # The set the picker last chose from, resolved through the home symlink
    # so a rebuilt store path is picked up; ~/Pictures/Wallpapers, the single
    # set named in variables.nix, until the picker has chosen one.
    dir=$(readlink -f "$HOME/.local/state/omnixy/current/background-set" 2>/dev/null || true)
    if [ -z "$dir" ] || [ ! -d "$dir" ]; then
      dir="$HOME/Pictures/Wallpapers"
    fi
    [ -d "$dir" ] || exit 0
    current=$(readlink "$HOME/.local/state/omnixy/current/background" 2>/dev/null || true)
    img=$(find -L "$dir" -maxdepth 1 -type f \
      \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.gif' -o -iname '*.bmp' -o -iname '*.webp' \) \
      | grep -vFx "$current" | shuf -n 1 || true)
    # Plain && would fail the unit under set -e when the only image is
    # already current and the pick comes back empty.
    if [ -n "$img" ]; then
      omnixy-theme-bg-set "$img"
    fi
  '';

  # One background picker per wallpaper set (decision: a single flat picker
  # over every set would ask omnixy-menu-images to thumbnail some four
  # thousand images before it could draw anything). Picking also retargets
  # rotation at the set the choice came from, so the two-minute timer cannot
  # drop the pick back into whichever set it was running on before.
  backgroundSetSwitcher = pkgs.writeShellScriptBin "omnixy-background-set-switcher" ''
    set -euo pipefail

    name="''${1:-}"
    if [ -z "$name" ]; then
      echo "Usage: omnixy-background-set-switcher <set>" >&2
      exit 1
    fi

    dir="$HOME/Pictures/WallpaperSets/$name"
    if [ ! -d "$dir" ]; then
      echo "No such background set: $name" >&2
      exit 1
    fi

    current=$(readlink -f "$HOME/.local/state/omnixy/current/background" 2>/dev/null || true)
    picked=$(omnixy-menu-images --selected "$current" "$dir")
    [ -n "$picked" ] || exit 0

    ln -nsf "$dir" "$HOME/.local/state/omnixy/current/background-set"
    omnixy-theme-bg-set "$picked"
  '';

  # omnixy-menu-images generates every missing thumbnail before it draws the
  # picker, and the larger sets run to a couple of thousand images, so the
  # first open of one would hang the menu for minutes. Generating them once
  # per session start, off the interactive path, keeps the picker instant;
  # the run is a no-op once the cache is warm.
  cacheBackgroundThumbnails = pkgs.writeShellScript "omnixy-background-thumbnails" ''
    set -euo pipefail

    dirs=()
    for dir in "$HOME/Pictures/WallpaperSets"/*; do
      # An if, not a && chain: the chain is the loop body's last command, so
      # under set -e an entry that is not a directory -- an unmatched glob
      # among them -- would end the unit as a failure.
      if [ -d "$dir" ]; then
        dirs+=("$dir")
      fi
    done
    [ ''${#dirs[@]} -gt 0 ] || exit 0

    omnixy-menu-images --cache-only "''${dirs[@]}"
  '';

  # Style -> Background becomes a submenu: the theme's own backgrounds first,
  # then one row per wallpaper set. Overriding the default row means
  # restating its aliases, since mergeMenuSources in the shell's MenuModel.js
  # replaces fields rather than deep-merging them, and the wallsetter keybind
  # reaches the submenu through `omnixy-menu toggle background`. Dropping
  # the default row's action is what turns it from an action into a submenu.
  backgroundMenu = [
    {
      id = "style.background";
      row = {
        icon = "";
        label = "Background";
        aliases = [
          "background"
          "wallpaper"
        ];
      };
    }
  ]
  ++ map (set: {
    id = "style.background.${set}";
    row = {
      icon = "";
      label = setLabel set;
      action = "omnixy-background-set-switcher ${set}";
    };
  }) wallpaperSets;

  # The upstream shell offers a connect/disconnect bluetooth dropdown and a
  # "restart bluetooth" row where classic reached blueman-manager for pairing,
  # trusting and renaming. blueman is enabled on the host and omnixy already
  # floats its window, so the manager only needed a way in. It sits beside
  # setup.network, the row upstream gives the other radio.
  bluetoothMenu = [
    {
      id = "setup.bluetooth";
      row = {
        icon = "󰂯";
        label = "Bluetooth";
        aliases = [
          "bluetooth"
          "pair"
        ];
        action = "blueman-manager";
      };
    }
  ];

  # Written by hand rather than through builtins.toJSON on one attribute set,
  # which would sort the rows and drop Theme below the nine sets: the shell
  # lists a submenu in the order its keys are parsed.
  menuExtensionsText = ''
    {
    ${lib.concatMapStringsSep ",\n" (
      entry: "  ${builtins.toJSON entry.id}: ${builtins.toJSON entry.row}"
    ) (backgroundMenu ++ bluetoothMenu)}
    }
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
    [ -e "$HOME/.local/state/omnixy/indicators/stay-awake" ] && exit 0
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

  # Bar modules replacing the waybar widgets the upstream bar lacks (decision
  # record: agents/2026-09-01-001, backlog item 1). systemstats reuses
  # waybar's exec line through the bar's custom command module; pushover and
  # workspaces are custom qml modules installed below.
  systemstatsModule = {
    id = "custom.systemstats";
    exec = ''echo "󰍛 $(free | awk '/Mem:/ {printf "%.0f%%", ($3/$2)*100}') | 󰻠 $(cat /proc/pressure/cpu | awk '/^some/ {print $2}' | cut -d= -f2) | 󰋊 $(df -h / | awk 'NR==2 {print $5}')"'';
    interval = 5;
    tooltip = "Memory used | CPU pressure | root disk used";
    onClick = "omnixy-launch-floating-terminal-with-presentation btop";
  };

  pushoverModule = {
    id = "custom.pushover";
    source = "~/.config/omnixy/bar/modules/Pushover.qml";
  };

  # Upstream's omnixy.workspaces stops at five; this one follows the
  # twenty-two the classic keybindings reach.
  workspacesModule = {
    id = "custom.workspaces";
    source = "~/.config/omnixy/bar/modules/Workspaces.qml";
  };

  # The classic waybar split, module for module: the top bar carries the tray
  # and the system readouts, the bottom bar the launcher, workspaces, window
  # title and status cluster. `bar.bottom` is the custom.bar plugin's own key
  # -- the stock bar ignores it, so a shell.json carrying it stays valid.
  barLayout = {
    id = "custom.bar";
    position = "top";
    centerAnchor = "";
    layout = {
      left = [ { id = "omnixy.tray"; } ];
      center = [
        systemstatsModule
        # Classic's custom/codexbar; the upstream widget covers the same
        # per-model AI usage and more.
        { id = "omnixy.agents"; }
      ];
      right = [
        { id = "omnixy.keyboard-layout"; }
        { id = "omnixy.weather"; }
        { id = "omnixy.monitor"; }
        { id = "omnixy.network"; }
        { id = "omnixy.audio"; }
        { id = "omnixy.microphone"; }
      ];
    };
    bottom = {
      position = "bottom";
      centerAnchor = "omnixy.active-window";
      layout = {
        left = [
          { id = "omnixy.menu"; }
          workspacesModule
        ];
        center = [ { id = "omnixy.active-window"; } ];
        right = [
          pushoverModule
          # Classic's custom/notification lives here as the shell's own
          # indicator strip, do-not-disturb included.
          { id = "omnixy.indicators"; }
          { id = "omnixy.system-update"; }
          { id = "omnixy.bluetooth"; }
          # Classic's battery module.
          { id = "omnixy.power"; }
          {
            id = "omnixy.clock";
            format = "dddd HH:mm";
            formatAlt = "d MMMM 'W'ww yyyy";
          }
        ];
      };
    };
  };
in
{
  xdg.configFile = {
    # Session entry point; the greeter wrapper passes
    # --config ~/.config/hypr/omnixy.lua and exports OMNIXY_PATH.
    "hypr/omnixy.lua".text = ''
      -- Generated by shared/wm/omnixy/default.nix. Follows upstream's
      -- config/hypr/hyprland.lua template, with classic keybindings
      -- replacing the upstream defaults.
      dofile((os.getenv("OMNIXY_PATH") or "${shell}") .. "/default/hypr/bootstrap.lua")

      omnixy_default_bindings = false

      require("default.hypr.omnixy")

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
      -- back to "us"; override with the configured layout. It also sets
      -- touchpad.natural_scroll = false, which inverts scrolling against
      -- classic, so the classic value is restated here.
      hl.config({
          input = {
              kb_layout = "${keyboardLayout}",
              touchpad = {
                  natural_scroll = true,
                  -- Upstream turns on clickfinger, which drops the corner
                  -- click zones and moves right-click to a two-finger click.
                  -- Classic left it off, where right-click is the bottom
                  -- right corner.
                  clickfinger_behavior = false,
              },
          },
      })
    '';

    # Environment (decision record: agents/2026-09-02-001, backlog item 13).
    # default/hypr/envs.lua already covers the Wayland handoff -- GDK_BACKEND,
    # QT_QPA_PLATFORM, MOZ_ENABLE_WAYLAND, the XDG_* trio -- so only what is
    # specific to this system, or to a deliberate classic choice, is added.
    # Deliberately not ported: classic's EDITOR, which the desktop owns through
    # omnixy-default-editor, and its GDK_SCALE/QT_SCALE_FACTOR pins, which
    # are no-ops at the scale this host runs.
    "omnixy-cfg/env.lua".text = ''
      -- Loaded after default.hypr.omnixy, so these win where they overlap.

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

      -- Qt validates its on-disk QML cache (~/.cache/quickshell/qmlcache)
      -- against the source file's mtime, and every file in the Nix store
      -- carries mtime 1. A rebuilt bar plugin therefore keeps loading from
      -- the cache compiled for the previous store path until the cache is
      -- deleted by hand. Compiling the shell's QML on every start costs well
      -- under a second and makes a Home Manager switch plus
      -- omnixy-restart-shell sufficient.
      hl.env("QML_DISABLE_DISK_CACHE", "1")
    '';

    # Window rules (decision record: agents/2026-09-02-001, backlog item 12).
    # Upstream's default/hypr/apps covers the applications it ships with, so
    # this carries only the two things classic does that it does not.
    "omnixy-cfg/rules.lua".text = ''
      -- Loaded after default.hypr.omnixy, so these append to its rules.

      -- Upstream inhibits idle only for named applications -- retroarch,
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
      -- the user manager and dbus on hyprland.start, and omnixy.lua requires
      -- it before this file is reached, so the variables session services
      -- need are on their way. Both calls are fire-and-forget, though, so a
      -- service starting here can still beat the import; units that need
      -- WAYLAND_DISPLAY have to tolerate arriving early rather than assume it.
      hl.on("hyprland.start", function()
          hl.exec_cmd("systemctl --user start omnixy-session.target")
      end)
    '';

    "omnixy/bar/modules/Pushover.qml".source = ./Pushover.qml;
    "omnixy/bar/modules/Workspaces.qml".source = ./Workspaces.qml;

    # A bar option, selected by bar.id in shell.json. The shell discovers it
    # by scanning ~/.config/omnixy/plugins for manifests, and only reads
    # from there, so store symlinks are enough.
    "omnixy/plugins/omnixy-bar/manifest.json".source = ./bar/manifest.json;
    "omnixy/plugins/omnixy-bar/Bar.qml".source = ./bar/Bar.qml;

    # Menu rows merged over default/omnixy/omnixy-menu.jsonc by id. The
    # shell watches this file, so a rebuild reaches an open session without a
    # restart.
    "omnixy/extensions/omnixy-menu.jsonc".text = menuExtensionsText;

    "omnixy-cfg/classic-binds.lua".text = catalogToLua classicCatalog;
  };

  home.packages = [ backgroundSetSwitcher ];

  # Every rotating wallpaper set, which is what the picker rows and the
  # rotation timer read. Classic's ~/Pictures/Wallpapers (the one set named in
  # variables.nix) is left alone: its wallsetter and the rotation fallback
  # both still read it.
  home.file = wallpaperSetLinks // {
    # The menu selects the icon font by family name; nothing else installs it.
    ".local/share/fonts/omnixy.ttf".source = "${shell}/default/fonts/omnixy/omnixy.ttf";
  };
  fonts.fontconfig.enable = true;

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
    # the omnixy session by the target. omnixy-theme-bg-set needs the
    # desktop bin and runtime tools for its omnixy-shell IPC call; the
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
          "PATH=${shell}/bin:${shell.runtimePath}:${
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

    services.omnixy-background-thumbnails = {
      Unit = {
        Description = "Cache background picker thumbnails for the wallpaper sets";
        PartOf = [ "omnixy-session.target" ];
        After = [ "omnixy-session.target" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${cacheBackgroundThumbnails}";
        # A cold cache is a few thousand vipsthumbnail runs across every
        # core; the desktop coming up has first claim on both.
        Nice = 19;
        IOSchedulingClass = "idle";
        # omnixy-menu-images reaches vipsthumbnail through the desktop
        # runtime path, and returns before any omnixy-shell IPC under
        # --cache-only, so it needs no display.
        Environment = [
          "PATH=${shell}/bin:${shell.runtimePath}:${
            lib.makeBinPath [
              pkgs.bash
              pkgs.coreutils
              pkgs.diffutils
              pkgs.findutils
              pkgs.gawk
              pkgs.util-linux
            ]
          }"
        ];
      };
      Install.WantedBy = [ "omnixy-session.target" ];
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
        Environment = [
          "PATH=${
            lib.makeBinPath [
              pkgs.hyprland
              pkgs.coreutils
            ]
          }"
        ];
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

  # default/hypr resolves omnixy.current.theme.* from ~/.local/state/omnixy;
  # seed a theme so the first login is themed. omnixy-theme-set owns the
  # tree afterwards.
  home.activation.omnixySeedTheme = lib.hm.dag.entryAfter [ "omnixyMigrateState" ] ''
    state="$HOME/.local/state/omnixy/current"
    if [ ! -e "$state/theme" ]; then
      mkdir -p "$state"
      cp -r "${shell}/themes/catppuccin-latte" "$state/theme"
      chmod -R u+w "$state/theme"
      echo catppuccin-latte > "$state/theme.name"
    fi
  '';

  # Writable plugin/theme/hook directories the desktop expects to own.
  home.activation.omnixyConfigDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/.config/omnixy/themes" \
             "$HOME/.config/omnixy/plugins" \
             "$HOME/.config/omnixy/hooks"
  '';

  # One-time carry-over from the directories this profile, under its old name,
  # used until 2026-09-04: the current theme and background, the bar
  # layout the user arranged, the font base-size override, and a warm
  # thumbnail cache. Each copy runs only while its destination is absent,
  # and the sources are left for the user to remove. The layout is renamed
  # in transit: the shell takes a valid user file as authoritative without
  # merging defaults, so old widget ids would draw an empty bar.
  home.activation.omnixyMigrateState = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    old="$HOME/.local/state/omarchy"; new="$HOME/.local/state/omnixy"
    if [ -d "$old" ] && [ ! -e "$new" ]; then
      cp -a "$old" "$new"; chmod -R u+w "$new"
    fi
    if [ -f "$HOME/.config/omarchy/shell.json" ] && [ ! -e "$HOME/.config/omnixy/shell.json" ]; then
      mkdir -p "$HOME/.config/omnixy"
      ${pkgs.gnused}/bin/sed \
        -e 's/"omnixy\.bar"/"custom.bar"/g' \
        -e 's/omarchy\./omnixy./g' \
        -e 's/omarchy-/omnixy-/g' \
        -e 's#\.config/omarchy#.config/omnixy#g' \
        -e 's#state/omarchy#state/omnixy#g' \
        "$HOME/.config/omarchy/shell.json" > "$HOME/.config/omnixy/shell.json"
    fi
    if [ -f "$HOME/.config/omarchy/shell.toml" ] && [ ! -e "$HOME/.config/omnixy/shell.toml" ]; then
      mkdir -p "$HOME/.config/omnixy"
      cp "$HOME/.config/omarchy/shell.toml" "$HOME/.config/omnixy/shell.toml"
    fi
  '';

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
  home.activation.omnixyBarLayout = lib.hm.dag.entryAfter [ "writeBoundary" "omnixyMigrateState" ] ''
    cfg="$HOME/.config/omnixy/shell.json"
    jq=${pkgs.jq}/bin/jq
    apply='.bar.id = $bar.id
      | .bar.position = $bar.position
      | .bar.centerAnchor = $bar.centerAnchor
      | .bar.layout = $bar.layout
      | .bar.bottom = $bar.bottom
      | .idle = $idle'
    args=(--argjson bar ${lib.escapeShellArg (builtins.toJSON barLayout)}
          --argjson idle ${lib.escapeShellArg (builtins.toJSON idleTimings)})

    mkdir -p "$HOME/.config/omnixy"
    if [ ! -e "$cfg" ]; then
      "$jq" "''${args[@]}" "$apply" "${shell}/config/omnixy/shell.json" >"$cfg"
    elif ! "$jq" -e 'has("bar") and (.bar | has("bottom"))' "$cfg" >/dev/null; then
      "$jq" "''${args[@]}" "$apply" "$cfg" >"$cfg.omnixy" && mv "$cfg.omnixy" "$cfg"
    fi
  '';
}
