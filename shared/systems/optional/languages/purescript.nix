{ pkgs, ...}:
{
  environment.systemPackages = with pkgs ;[
    purescript
  ];

}
