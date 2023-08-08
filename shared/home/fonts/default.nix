{
  config,
  pkgs,
  ...
}: let
  nfversion = "3.0.2";
  build-font = pname: phash: pzip: striproot: pkgs.callPackage ./fonts/build-font {inherit nfversion pname phash pzip striproot;};
  jetbrainsmono-nerdfont = build-font "jetbrainsmono-nerdfont" "JIodr+3KuVvWMVmvTd0KgYMwsLfHgk/5Hvx/z/DOkZk=" "JetBrainsMono.zip" false;
  firacode-nerdfont = build-font "firacode-nerdfont" "AeXvD9xhaPscfIUb7nvubzK664Bk1f1lNygAYhE95nk=" "Firacode.zip" false;
  hasklig-nerdfont = build-font "hasklig-nerdfont" "pfZrr7jB8gP/4wW+6qR5WZK2cnLPn6+lZGAH1gRG4Rw=" "Hasklig.zip" false;
in {
  home.packages = with pkgs; [
    fira-code
    fira-code-symbols
    font-awesome
    jetbrainsmono-nerdfont
    hasklig-nerdfont
    firacode-nerdfont
  ];
}
