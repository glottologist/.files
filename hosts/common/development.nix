{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  environment.systemPackages = with pkgs; [
    binutils
    coreutils
    cmake
    gnumake
    bruno
    insomnia
    websocat
  ];
}
