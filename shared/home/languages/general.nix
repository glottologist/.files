{ pkgs, ...}:
{
  home.packages = with pkgs; [
    gnumake
    cmake
    pkg-config
    libsodium
  ];
}
