{
  config,
  lib,
  pkgs,
  stdenv,
  ...
}: {
  home.packages = with pkgs; [
    xivlauncher
    jmtpfs
    libmtp
  ];
  imports = [
  ];
}
