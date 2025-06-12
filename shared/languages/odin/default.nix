{pkgs, ...}: {
  home.packages = with pkgs; [
    nasm
    ols
    clang
    gnumake
    gdb
  ];
}
