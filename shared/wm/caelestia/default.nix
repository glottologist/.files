{
  pkgs,
  lib,
  username,
  caelestia-dots,
  ...
}: let
  inherit
    (import ../../../homes/${username}/variables.nix)
    browser
    terminal
    keyboardLayout
    extraMonitorSettings
    ;

  # Translate hyprlang "monitor=output,mode,position,scale" lines from
  # variables.nix into hl.monitor calls for the Lua config.
  monitorLines =
    builtins.filter
    (line: lib.hasPrefix "monitor=" line)
    (lib.splitString "\n" extraMonitorSettings);
  toLuaMonitor = line: let
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
in {
  programs.caelestia = {
    enable = true;
    cli.enable = true;
    # greetd launches Hyprland directly, so graphical-session.target never
    # activates and the unit would sit idle; execs.lua starts the shell
    # with `caelestia shell -d` as upstream intends.
    systemd.enable = false;
  };

  # The dots treat ~/.config/hypr as immutable, so store symlinks match the
  # upstream contract. scheme/ must stay a real writable directory:
  # hyprland.lua copies default.lua to current.lua at load, and
  # `caelestia scheme set` rewrites current.lua at runtime.
  xdg.configFile = {
    "hypr/hyprland.lua".source = "${caelestia-dots}/hypr/hyprland.lua";
    "hypr/variables.lua".source = "${caelestia-dots}/hypr/variables.lua";
    "hypr/hyprland".source = "${caelestia-dots}/hypr/hyprland";
    "hypr/utils".source = "${caelestia-dots}/hypr/utils";
    "hypr/scheme/default.lua".source = "${caelestia-dots}/hypr/scheme/default.lua";

    "caelestia/hypr-vars.lua".text = ''
      return {
          terminal = "${terminal}",
          browser  = "${browser}",
      }
    '';

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
