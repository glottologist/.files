{username, ...}: let
  inherit (import ../../homes/${username}/variables.nix) waybarChoice;
in {
  imports = [
    ./stylix.nix
    waybarChoice
     ./hyprland/default.nix
    ./rofi/default.nix
    ./scripts/default.nix
    ./wlogout/default.nix
  ];
}
