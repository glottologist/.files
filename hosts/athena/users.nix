{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (import ./variables.nix) username;
in {
  users.users = {
    "${username}" = {
      isNormalUser = true;
      shell = pkgs.fish;
      description = "${username}";
      extraGroups = ["wheel"];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILN1szb/fBxMMUgpClXaFd4zR71B5/02Ij9jV4wxKW+o jason@glottologist.co.uk"
      ];
    };
  };
}
