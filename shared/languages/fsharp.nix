{pkgs, ...}: {
  home.packages = with pkgs; [
    dotnetPackages.NUnitConsole
    dotnetPackages.Paket
    dotnetbuildhelpers
    fsautocomplete
  ];
}
