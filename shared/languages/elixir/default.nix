{pkgs, ...}: {
  home.packages = with pkgs; [
    elixir
    elixir-ls
    erlfmt
    rebar3
  ];
}
