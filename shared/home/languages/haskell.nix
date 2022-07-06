{ pkgs, ...}:
{
  home.packages = with pkgs; [
    ghc
    cachix
    pandoc
    hlint
    ormolu
    #brittany                # code formatter
    cabal2nix               # convert cabal projects to nix
    cabal-install           # package manager
    ghc                     # compiler
    haskell-language-server # haskell IDE (ships with ghcide)
    #hoogle                  # documentation
    nix-tree                # visualize nix dependencies
  ];



}
