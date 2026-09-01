# Nix guideline compliant 2026-09-01
{ pkgs }:
pkgs.writeShellScriptBin "list-keybinds" (builtins.readFile ./keybinds.sh)
