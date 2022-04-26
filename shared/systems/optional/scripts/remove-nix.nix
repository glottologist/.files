{ pkgs, ... }:

let
  remove-nix = pkgs.writeScriptBin "remove-nix" ''
    #!${pkgs.stdenv.shell}
     rm -rf $HOME/.nix-*
     rm -rf $HOME/.cache/nix
     rm -rf $HOME/.config/nixpkgs

     if [ -e '/etc/bashrc.backup-before-nix' ]; then
       sudo mv -f /etc/bashrc.backup-before-nix /etc/bashrc
     fi

     if [ -e '/etc/profile.d/nix.sh.backup-before-nix' ]; then
       sudo mv -f /etc/profile.d/nix.sh.backup-before-nix /etc/profile.d/nix.sh
     fi

     if [ -e ' /etc/zshrc.backup-before-nix' ]; then
     sudo mv -f /etc/zshrc.backup-before-nix /etc/zshrc
     fi

     sudo rm -rf /nix

  '';
in {
  environment.systemPackages = [ remove-nix ];
}
