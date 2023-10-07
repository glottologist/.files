{
  config,
  lib,
  pkgs,
  stdenv,
  ...
}: {
  imports = [
    ./git/default.nix
    ./neovim/default.nix
    #./vscode/default.nix
    #./jetbrains/default.nix
  ];

  home.packages = with pkgs; [
    difftastic # A syntax-aware diff
    earthly # Build automation for the container era
    helix # A post-modern modal text editor
    jupyter # The Jupyter HTML notebook is a web-based notebook environment for interactive computing
    logkeys # A GNU/Linux keylogger that works! 
    netlify-cli # CLI to manage netlify deployments
    newman # A command line runner for Postman
    pkg-config # A tool that allows packages to find out information about other packages (wrapper script)
    # postman # API Development Environment - TODO Couldn't download 10.18.6 from any mirror 7th OCt 23
    remarshal # Convert between TOML, YAML and JSON
    rpi-imager # Raspberry Pi Imaging Utility
    silver-searcher # Ack like searcher focused on code
    universal-ctags # A maintained ctags implementation
    usbutils # USb Utlities
  ];

  programs = {
  };

  services = {
    #lorri.enable = true;
  };
}
