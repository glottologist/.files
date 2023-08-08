{
  config,
  pkgs,
  ...
}: let
  nfversion = "3.0.2";
  build-font = pname: phash: pzip: striproot: pkgs.callPackage ./fonts/build-font {inherit nfversion pname phash pzip striproot;};
  jetbrainsmono-nerdfont = build-font "jetbrainsmono-nerdfont" "p6i6CTlDCGXH+puCINM69n4fLoIwBTgskbSBi7EbkJc=" "JetBrainsMono.zip" true;
  firacode-nerdfont = build-font "firacode-nerdfont" "AeXvD9xhaPscfIUb7nvubzK664Bk1f1lNygAYhE95nk=" "Firacode.zip" false;
  hasklig-nerdfont = build-font "hasklig-nerdfont" "Shtvt79mzVdrXytWNdkTUQXr5VnSbUPXAwsOp9ZqX3c=" "Hasklig.zip" false;
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
