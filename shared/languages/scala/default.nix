{pkgs, ...}: {
  home.packages = with pkgs; [
    scala_3
    metals
    coursier
    scalafmt
    sbt
    mill
    scala-cli
  ];
}
