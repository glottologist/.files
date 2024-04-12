{
  config,
  lib,
  pkgs,
  stdenv,
  ...
}: {
  imports = [
    ./git/default.nix
    # ./neovim/default.nix
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
    poedit # Cross-platform gettext catalogs (.po files) editor
    remarshal # Convert between TOML, YAML and JSON
    rpi-imager # Raspberry Pi Imaging Utility
    screenkey  #A screencast tool to display your keys inspired by Screenflick
    silver-searcher # Ack like searcher focused on code
    universal-ctags # A maintained ctags implementation
    usbutils # USb Utlities
    wakatime # Wakatime dev stats command line
    watchexec # Universal watcher
  ];

  programs = {
  };

  services = {
    lorri.enable = true;
  };
}
