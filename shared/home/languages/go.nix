{pkgs, ...}: {
  home.packages = with pkgs; [
    gcc
    go
    gopkgs
    go-outline
    gotests
    gomodifytags
    dep2nix
    impl
    gopls
    go-tools
  ];
}
