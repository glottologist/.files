{pkgs, ...}: {
  home.packages = with pkgs; [
    # brittany                # code formatter
    # hoogle                  # documentation
    cabal-install # package manager
    cabal2nix # convert cabal projects to nix
    cachix
    haskell-language-server # haskell IDE (ships with ghcide)
    hlint
    ormolu
    pandoc
    haskellPackages.ihaskell
  ];
}
