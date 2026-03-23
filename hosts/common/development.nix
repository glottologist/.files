{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  environment.systemPackages = with pkgs; [
    binutils
    bubblewrap
    coreutils
    cmake
    gnumake
    bruno
    insomnia
    openssl
    websocat
  ];
}
