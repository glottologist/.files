{ pkgs, ...}:
{
  environment.systemPackages = with pkgs ;[
    elm2nix
    elmPackages.elm-language-server

  ];
}
