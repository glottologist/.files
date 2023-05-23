{ config, lib, pkgs, stdenv, ... }:
{

  imports = [
    ./git/default.nix
    ./neovim/default.nix
    ./vscode/default.nix
    #./jetbrains/default.nix
  ];

  home.packages = with pkgs; [
    difftastic        # A syntax-aware diff
    earthly           # Build automation for the container era
    helix             # A post-modern modal text editor
    netlify-cli       # CLI to manage netlify deployments
    newman            # A command line runner for Postman
    pkg-config        # A tool that allows packages to find out information about other packages (wrapper script)
    postman           # API Development Environment
    remarshal         # Convert between TOML, YAML and JSON
    rpi-imager        # Raspberry Pi Imaging Utility
    silver-searcher   # Ack like searcher focused on code
    universal-ctags   # A maintained ctags implementation
  ];


  programs = {
  };

  services = {
    #lorri.enable = true;

  };
}
