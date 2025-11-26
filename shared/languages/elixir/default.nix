{pkgs, ...}: {
  home.packages = with pkgs; [
    elixir
    # elixir-ls removed - installs LICENSE/CHANGELOG.md to root causing conflicts
    # Use editor's LSP manager (mason.nvim, vscode extension) instead
    erlfmt
    rebar3
  ];
}
