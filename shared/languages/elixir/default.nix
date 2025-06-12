{pkgs, ...}: {
  home.packages = with pkgs; [
    elixir
    elixir-ls
    livebook
    erlfmt
    rebar3
  ];
}
