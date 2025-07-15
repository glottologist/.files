{
  config,
  pkgs,
  ...
}: let
  nfversion = "3.0.2";
  build-nerd-font = pname: phash: pzip: striproot: pkgs.callPackage ./fonts/build-nerd-font {inherit nfversion pname phash pzip striproot;};
  jetbrainsmono-nerdfont = build-nerd-font "jetbrainsmono-nerdfont" "JIodr+3KuVvWMVmvTd0KgYMwsLfHgk/5Hvx/z/DOkZk=" "JetBrainsMono.zip" false;
  firacode-nerdfont = build-nerd-font "firacode-nerdfont" "AeXvD9xhaPscfIUb7nvubzK664Bk1f1lNygAYhE95nk=" "Firacode.zip" false;
in {
  imports = [
    ./emoji.nix
  ];
  home.packages = with pkgs; [
    fira-code
    fira-code-symbols
    jetbrainsmono-nerdfont
    firacode-nerdfont
  ];
}
