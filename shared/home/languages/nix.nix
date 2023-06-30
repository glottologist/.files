{ pkgs, ...}:
{
  home.packages = with pkgs; [
    manix
    nix-doc
    nix-index
    #nix-linter
    nix-serve
    nix-template
    nix-top
    nix-tree
    nixfmt
    nixos-generators
    nixos-shell
    rnix-lsp
  ];
}
