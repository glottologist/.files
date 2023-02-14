{ pkgs, ...}:
{
  home.packages = with pkgs; [
    jdk11
    dotty
    sbt
    metals
    scalafmt
    nodePackages.coc-metals                 # metals extension for coc
  ];
}
