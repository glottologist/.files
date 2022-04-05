{ pkgs, ...}:
{
  environment.systemPackages = with pkgs ;[
    nodejs
    nodePackages.npm
    nodePackages.esy
    nodePackages.node2nix
  ];
}
