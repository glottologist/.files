{pkgs, ...}: {
  home.packages = with pkgs; [
    gopkgs
    go-outline
    gotests
    gomodifytags
    impl
    gopls
    go-tools
  ];
}
