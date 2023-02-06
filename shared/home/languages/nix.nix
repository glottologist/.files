{ pkgs, ...}:
{
  home.packages = with pkgs; [
    manix
    nix-index
    nix-linter
    nixfmt
    rnix-lsp
  ];
}
