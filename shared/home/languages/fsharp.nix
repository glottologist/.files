{ pkgs, ...}:
{
  home.packages = with pkgs; [
    dotnetCorePackages.sdk_7_0
    fsharp
    dotnetPackages.NUnitConsole
    dotnetPackages.Paket
    dotnetbuildhelpers

  ];
}
