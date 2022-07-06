{ pkgs, ...}:
{
  environment.systemPackages = with pkgs ;[
    gnat

  ];
}
