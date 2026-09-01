# Nix guideline compliant 2026-09-01
{
  pkgs,
  lib,
  username,
  caelestia-dots,
  ...
}:
let
  inherit (import ../../../homes/${username}/variables.nix)
    browser
    terminal
    keyboardLayout
    extraMonitorSettings
    ;

  # The caelestia session replays the annotated Classic catalog.
  classicCatalog = import ../hyprland/keybind-catalog.nix { inherit username; };
  catalogToLua = import ../hyprland/catalog-to-lua.nix { inherit lib; };

  # Every dots module except keybinds.lua, which ./keybinds.lua replaces.
  # Derived from the dots so an upstream module addition fails loudly at
  # build time (missing require) rather than silently keeping stale files.
  dotsHyprModules = builtins.filter (name: name != "keybinds.lua") (
    builtins.attrNames (builtins.readDir "${caelestia-dots}/hypr/hyprland")
  );

  # Translate hyprlang "monitor=output,mode,position,scale" lines from
  # variables.nix into hl.monitor calls for the Lua config.
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
in
{
  programs.caelestia = {
    enable = true;
    cli.enable = true;
    # The session wrapper launches Hyprland directly, so
    # graphical-session.target never activates and the unit would sit idle;
    # execs.lua starts the shell with `caelestia shell -d` as upstream intends.
    systemd.enable = false;
  };

  # The dots treat ~/.config/hypr as immutable, so store symlinks match the
  # upstream contract. scheme/ must stay a real writable directory:
  # hyprland.lua copies default.lua to current.lua at load, and
  # `caelestia scheme set` rewrites current.lua at runtime.
  xdg.configFile =
    lib.listToAttrs (
      map (
        name:
        lib.nameValuePair "hypr/hyprland/${name}" {
          source = "${caelestia-dots}/hypr/hyprland/${name}";
        }
      ) dotsHyprModules
    )
    // {
      "hypr/hyprland.lua".source = "${caelestia-dots}/hypr/hyprland.lua";
      "hypr/variables.lua".source = "${caelestia-dots}/hypr/variables.lua";
      "hypr/hyprland/keybinds.lua".source = ./keybinds.lua;
      "hypr/utils".source = "${caelestia-dots}/hypr/utils";
      "hypr/scheme/default.lua".source = "${caelestia-dots}/hypr/scheme/default.lua";

      # Classic bindings serialised for keybinds.lua; hyprland.lua puts
      # ~/.config/caelestia on package.path, so require("classic-binds")
      # resolves here.
      "caelestia/classic-binds.lua".text = catalogToLua classicCatalog;

      "caelestia/hypr-vars.lua".text = ''
        return {
            terminal = "${terminal}",
            browser  = "${browser}",
        }
      '';

      # The CLI's scheme engine writes ~/.config/gtk-{3,4}.0/{gtk,thunar}.css
      # and dconf's gtk-theme on every scheme apply. Those files are per-user,
      # not per-session, so a caelestia login used to darken GTK apps in the
      # classic session too; enableGtk = false keeps its theming inside the
      # caelestia shell.
      "caelestia/cli.json".text = builtins.toJSON {
        theme.enableGtk = false;
      };

      "caelestia/hypr-user.lua".text = ''
        -- input.lua hardcodes kb_layout = "us"
        hl.config({
            input = {
                kb_layout = "${keyboardLayout}",
            },
        })

        ${lib.concatStrings (map toLuaMonitor monitorLines)}
        hl.on("hyprland.start", function()
            -- execs.lua points at /usr/lib, which does not exist on NixOS
            hl.exec_cmd("${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1")
        end)
      '';
    };

  # Tools the dots' execs.lua and keybinds.lua invoke.
  home.packages = with pkgs; [
    wl-clipboard
    cliphist
    trash-cli
    hyprpicker
    fuzzel
    gnome-keyring
  ];
}
