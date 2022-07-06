{ pkgs, ...}:
{
  home.packages = with pkgs; [
    solc
    sbt
    metals
  ];
}
