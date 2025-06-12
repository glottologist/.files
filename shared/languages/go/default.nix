{pkgs, ...}: {
  home.packages = with pkgs; [
    delve
    go-outline
    go-tools
    gomodifytags
    gopkgs
    gopls
    gotests
    gotools
    iferr
    impl
  ];
}
