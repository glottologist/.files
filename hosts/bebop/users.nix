{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: let
  inherit (import ./variables.nix) username;
in {
  users.users = {
    "${username}" = {
      isNormalUser = true;
      shell = pkgs.fish;
      description = "${username}";
      extraGroups = ["wheel" "networkmanager" "podman" "plugdev" "libvirt" "libvirtd" "pulse" "audio"];
    };
  };
}
