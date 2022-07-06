{ pkgs, ...}:
{
  home.packages = with pkgs; [
    jdk11
    scala
    sbt
    #metals
  ];
}
