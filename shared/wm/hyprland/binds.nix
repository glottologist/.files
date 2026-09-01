# Nix guideline compliant 2026-09-01
{ username, ... }:
let
  catalog = import ./keybind-catalog.nix { inherit username; };
  render =
    record:
    let
      fields = builtins.match "([^,]*),([^,]*),(.*)" record.binding;
    in
    assert fields != null;
    builtins.concatStringsSep "," [
      (builtins.elemAt fields 0)
      (builtins.elemAt fields 1)
      "[${record.group}] ${record.description}"
      (builtins.elemAt fields 2)
    ];
in
{
  xdg.configFile."hypr/binding-loader.lua".source = ./binding-loader.lua;

  wayland.windowManager.hyprland.settings = {
    bindd = builtins.map render catalog.bind;
    bindmd = builtins.map render catalog.bindm;
  };
}
