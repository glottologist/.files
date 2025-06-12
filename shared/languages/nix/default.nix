{pkgs, ...}: {
  home.packages = with pkgs; [
    cachix
    deadnix
    manix
    nil
    nix-doc
    nix-index
    nix-serve
    nix-template
    nix-top
    nix-tree
    nixfmt-classic
    nixos-generators
    nixos-shell
    nox
    statix
    vulnix
  ];
}
