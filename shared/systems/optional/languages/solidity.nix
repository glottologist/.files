{ pkgs, ...}:
{
  environment.systemPackages = with pkgs ;[
    solc
    sbt
    metals
  ];
}
