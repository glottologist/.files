{pkgs, ...}: {
  home.packages = with pkgs; [
    stdenv
    gnumake
    ccls
    pkg-config
    gdb
    valgrind
  ];
}
