{ pkgs, ...}:
{
  home.packages = with pkgs; [
    kotlin  # General purpose programming language
    kotlin-native # A modern programming language that makes developers happier
    kotlin-language-server # kotlin language server
    gradle




  ];

}
