{ pkgs, ... }:

let
  remove-nix = pkgs.writeScriptBin "remove-nix" ''
    #!${pkgs.stdenv.shell}
     rm -rf $HOME/.nix-*
     rm -rf $HOME/.cache/nix
     rm -rf $HOME/.config/nixpkgs
     sudo mv -f /etc/bashrc.backup-before-nix /etc/bashrc
     sudo rm -rf /nix
  '';
in {
  environment.systemPackages = [ remove-nix ];
}
