{ pkgs, ...}:
{
  home.packages = with pkgs; [
    dotnet-sdk_5
    mono
    fsharp
    dotnetPackages.NUnitConsole
   #dotnetPackages.NUnitRunners
    dotnetPackages.Paket
    dotnetbuildhelpers

  ];
}
