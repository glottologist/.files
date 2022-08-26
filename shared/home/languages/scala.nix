{ pkgs, ...}:
{
  home.packages = with pkgs; [
    jdk11
    dotty
    sbt
    metals
    scalafmt
  ];
}
