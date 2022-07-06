{ pkgs, ...}:
{
  home.packages = with pkgs; [
    nodejs
    yarn
    nodePackages.npm
    nodePackages.esy
    nodePackages.node2nix
  ];
}
