{ config, pkgs, ... }:
let
  nfversion = "3.0.2";
  nerdfont-firacode = pkgs.callPackage ./fonts/firacode-nerdfont { inherit nfversion; };
  jetbrainsmono-firacode = pkgs.callPackage ./fonts/firacode-nerdfont { inherit nfversion; };
  hasklig-firacode = pkgs.callPackage ./fonts/hasklig-nerdfont { inherit nfversion; };
in
{
  home.packages = with pkgs; [
    fira-code
    fira-code-symbols
    font-awesome
    jetbrainsmono-firacode
    hasklig-firacode
    nerdfont-firacode
  ];
}
