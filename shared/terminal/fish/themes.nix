
{
  config,
  lib,
  pkgs,
  stdenv,
  ...
}: {
  xdg.configFile."fish/themes/catppuccin_latte.theme".source = ./themes/catppuccin/latte.theme;
}
