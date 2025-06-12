{pkgs, ...}: {
  home.packages = with pkgs; [
  erlang_27
  erlang-ls
  rebar3
  ];
}
