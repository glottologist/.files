{pkgs, ...}: {
  home.packages = with pkgs; [
    stdenv
    gnumake
    ccls
    gdb
    valgrind
  ];
}
