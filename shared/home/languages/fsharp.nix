{ pkgs, ...}:
{
  home.packages = with pkgs; [
    dotnet-sdk_7
    mono
    fsharp
    dotnetPackages.NUnitConsole
   #dotnetPackages.NUnitRunners
    dotnetPackages.Paket
    dotnetbuildhelpers

  ];
}
