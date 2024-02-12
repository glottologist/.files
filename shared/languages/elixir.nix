{pkgs, ...}: {
  home.packages = with pkgs; [
    elixir-ls
    livebook
    erlang-ls
    erlfmt
    rebar3
  ];
}
