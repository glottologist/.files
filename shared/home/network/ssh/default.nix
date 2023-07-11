{ config, pkgs, ... }:
let
  mb = (builtins.readFile ../../../../secrets/ssh_match_blocks.nix).blocks;
in
{
programs.ssh = {
    enable = true;
    extraConfig = /* sshconfig */ ''
      Include config_local
    '';
    matchBlocks = mb;
};
}
