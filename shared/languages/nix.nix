{pkgs, ...}: {
  home.packages = with pkgs; [
    manix
    nix-doc
    nix-index
    #nix-linter
    nix-serve
    nix-template
    nix-top
    nix-tree
    nixfmt-classic
    nixos-generators
    nixos-shell
    cachix
    statix
    vulnix
    deadnix
    nil
    nox
  ];
}
