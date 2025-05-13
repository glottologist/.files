{
  pkgs,
  lib,
  ...
}: {
  home.packages = with pkgs; [
    dotnetCorePackages.sdk_8_0
    dotnetPackages.NUnitConsole
    dotnetPackages.Paket
    dotnetbuildhelpers
    fsautocomplete
  ];
}
