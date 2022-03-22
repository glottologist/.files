{ pkgs, ...}:
{
  environment.systemPackages = with pkgs ;[
    nix-linter
    nixfmt
    rnix-lsp
  ];
}
