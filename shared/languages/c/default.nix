{pkgs, ...}: {
  home.packages = with pkgs; [
    stdenv
    gnumake
    ccls
    clang
    libclang
    gdb
    valgrind
  ];
}
