{
  config,
  lib,
  pkgs,
  stdenv,
  ...
}: {
  imports = [
    ./hyprland/default.nix
    ./rofi/default.nix
    ./scripts/default.nix
    ./wlogout/default.nix
    ./stylix.nix
  ];
}
