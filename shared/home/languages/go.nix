{pkgs, ...}: {
  home.packages = with pkgs; [
    gcc
    go
    dep2nix
    gopls
  ];
}
