{ pkgs, ...}:
{
  home.packages = with pkgs; [
    nix-linter
    nixfmt
    rnix-lsp
    nix-index
  ];
}
