{ pkgs, ...}:
{
  home.packages = with pkgs; [
    elm2nix
    elmPackages.elm-language-server

  ];
}
