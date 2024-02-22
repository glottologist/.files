{pkgs, ...}: {
  home.packages = with pkgs; [
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
