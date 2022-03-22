{ pkgs, ...}:
{
  environment.systemPackages = with pkgs ;[
    elixir
    erlang
  ];
}
