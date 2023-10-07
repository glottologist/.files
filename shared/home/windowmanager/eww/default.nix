
{
  config,
  lib,
  pkgs,
  stdenv,
  ...
}: {
  home.packages = with pkgs; [
    eww-wayland
  ];
  imports = [
  ];
}
