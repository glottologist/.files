{ config, lib, pkgs, stdenv, ... }:
{

  imports = [
    ./git/default.nix
    ./neovim/default.nix
    ./vscode/default.nix
    #./jetbrains/default.nix
  ];

  home.packages = with pkgs; [
    remarshal         # Convert between TOML, YAML and JSON
    pkg-config        # A tool that allows packages to find out information about other packages (wrapper script)
    universal-ctags   # A maintained ctags implementation
    silver-searcher   # Ack like searcher focused on code
    difftastic        # A syntax-aware diff
    rpi-imager        # Raspberry Pi Imaging Utility
    postman           # API Development Environment
    newman            # A command line runner for Postman
    earthly           # Build automation for the container era
    helix             # A post-modern modal text editor
  ];


  programs = {
  };

  services = {
    #lorri.enable = true;

  };
}
