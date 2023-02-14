{ pkgs, ...}:
{
  home.packages = with pkgs; [
                            # brittany                # code formatter
                            # hoogle                  # documentation
    cabal-install           # package manager
    cabal2nix               # convert cabal projects to nix
    cachix
    ghc
    ghc                     # compiler
    haskell-language-server # haskell IDE (ships with ghcide)
    hlint
    nix-tree                # visualize nix dependencies
    ormolu
    pandoc
  ];



}
