{
  config,
  lib,
  pkgs,
  stdenv,
  ...
}: {
  imports = [
  ];

  home.packages = with pkgs; [
    # davinci-resolve # Professional Video Editing, Color, Effects and Audio Post
    handbrake
  ];

  programs = {
  };

  services = {
  };
}
