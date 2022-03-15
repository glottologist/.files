{ config, lib, pkgs, stdenv, ... }:
{

  imports = [
    ./git/default.nix
    ./neovim/default.nix
    ./vscode/default.nix
    ./jetbrains/default.nix
  ];

  home.packages = with pkgs; [
    remarshal         # Convert between TOML, YAML and JSON
    pkg-config        # A tool that allows packages to find out information about other packages (wrapper script)
    universal-ctags   # A maintained ctags implementation
  ];


  programs = {
  };

  services = {
    lorri.enable = true;

  };
}
