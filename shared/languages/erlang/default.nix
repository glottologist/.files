{pkgs, ...}: {
  home.packages = with pkgs; [
    erlang_27
    erlang-language-platform
    rebar3
  ];
}
