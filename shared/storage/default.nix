{
  config,
  lib,
  pkgs,
  stdenv,
  ...
}: {
  home.packages = with pkgs; [
    xivlauncher
  ];
  imports = [
  ];
}
