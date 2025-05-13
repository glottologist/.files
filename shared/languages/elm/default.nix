{ pkgs, ...}:
{
  home.packages = with pkgs; [
     elmPackages.elm
      elmPackages.elm-format
      elmPackages.elm-test
      elmPackages.elm-language-server
      elm2nix

  ];
}
