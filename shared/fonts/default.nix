{
  config,
  pkgs,
  ...
}: let
  nfversion = "3.0.2";
  dcversion = "2.15.1";
  build-nerd-font = pname: phash: pzip: striproot: pkgs.callPackage ./fonts/build-nerd-font {inherit nfversion pname phash pzip striproot;};
  build-devicons = pname: phash: dcversion: striproot: pkgs.callPackage ./fonts/build-devicons {inherit pname phash dcversion striproot;};
  jetbrainsmono-nerdfont = build-nerd-font "jetbrainsmono-nerdfont" "JIodr+3KuVvWMVmvTd0KgYMwsLfHgk/5Hvx/z/DOkZk=" "JetBrainsMono.zip" false;
  firacode-nerdfont = build-nerd-font "firacode-nerdfont" "AeXvD9xhaPscfIUb7nvubzK664Bk1f1lNygAYhE95nk=" "Firacode.zip" false;
  devicons = build-devicons "devicon" "pfZrr7jB8gP/4wW+6qR5WZK2cnLPn6+lZGAH1gRG4Rw=" dcversion false;
in {
  home.packages = with pkgs; [
    fira-code
    fira-code-symbols
    font-awesome
    jetbrainsmono-nerdfont
    firacode-nerdfont
    #devicons
  ];
}
