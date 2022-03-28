{ pkgs, ...}:
{
  environment.systemPackages = with pkgs ;[
    gnumake
    cmake
    pkg-config

  ];
}
