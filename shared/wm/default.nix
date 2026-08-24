{username, ...}: let
  inherit (import ../../homes/${username}/variables.nix) desktopChoice;
in {
  imports = [
    ./stylix.nix
    desktopChoice
  ];
}
