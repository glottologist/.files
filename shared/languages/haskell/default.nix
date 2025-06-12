{pkgs, ...}: {
  home.packages = with pkgs; [
    cabal-install # package manager
    cabal2nix # convert cabal projects to nix
    ghc
    haskell-language-server # haskell IDE (ships with ghcide)
    haskellPackages.ihaskell
    hlint
    hpack
    ormolu
    pandoc
    stack
  ];
}
