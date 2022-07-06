{ pkgs, ...}:
{
  environment.systemPackages = with pkgs ;[
      fstar
  ];
}
