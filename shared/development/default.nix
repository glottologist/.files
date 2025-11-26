{
  config,
  lib,
  pkgs,
  nvim-flake,
  neovim-flake,
  stdenv,
  ...
}: {
  imports = [
    ./git/default.nix
    ./jj/default.nix
    ./vscode/default.nix
  ];

  home.packages = with pkgs; [
    devbox # Dev envs
    difftastic # A syntax-aware diff
    earthly # Build automation for the container era
    exercism # A Go based command line tool for exercism.io

    helix # A post-modern modal text editor
    jupyter # The Jupyter HTML notebook is a web-based notebook environment for interactive computing
    (vimPlugins.LazyVim.overrideAttrs (old: {
      installPhase =
        old.installPhase
        + ''
          rm -f $out/LICENSE
        '';
    }))
    leetcode-cli #A command-line tool for LeetCode
    leetgo #A command-line tool for LeetCode
    logkeys # A GNU/Linux keylogger that works!
    netlify-cli # CLI to manage netlify deployments
    newman # A command line runner for Postman
    #nvim-flake.packages.${system}.developer
    neovim-flake.packages.${system}.developer
    opencommit #AI-powered commit message generator
    poedit # Cross-platform gettext catalogs (.po files) editor
    remarshal # Convert between TOML, YAML and JSON
    rpi-imager # Raspberry Pi Imaging Utility
    screenkey #A screencast tool to display your keys inspired by Screenflick
    silver-searcher # Ack like searcher focused on code
    universal-ctags # A maintained ctags implementation
    usbutils # USb Utlities
    wakatime-cli # Wakatime dev stats command line
    watchexec # Universal watcher
    windsurf # Agentic IDE powered by AI Flow paradigm
    lftp # File transfer program supporting a number of network protocols
    filezilla # Graphical FTP, FTPS and SFTP client
  ];

  programs = {
    gh.enable = true;
  };

  services = {
    lorri.enable = true;
  };
}
