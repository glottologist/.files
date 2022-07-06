{ pkgs, ...}:
{
  environment.systemPackages = with pkgs ;[
    jdk11
    scala
    sbt
    #metals
  ];
}
