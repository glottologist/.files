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
    pv # Pipe viewer: progress meter for data flowing through a pipe
    websocat
  ];
}
