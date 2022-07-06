{ pkgs, ...}:
{
  environment.systemPackages = with pkgs ;[
    gcc
    go
    dep2nix
    gopls
  ];
}
