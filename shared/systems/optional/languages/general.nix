{ pkgs, ...}:
{
  environment.systemPackages = with pkgs ;[
    cmake
    pkg-config

  ];
}
