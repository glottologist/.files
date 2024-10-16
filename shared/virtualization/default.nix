{
  config,
  lib,
  pkgs,
  stdenv,
  ...
}: {
  home.packages = with pkgs; [
    lazydocker # TUI for Docker
    skopeo # A command line utility for various operations on container images and image repositories
    dive # Inspec docker image layers
    undocker # Convert image to rootfs
  ];

  imports = [
  ];
}
