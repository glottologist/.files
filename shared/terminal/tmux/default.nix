{
  config,
  pkgs,
  ...
}: let
  plugins = pkgs.tmuxPlugins // pkgs.callPackage ./plugins.nix {};
  tmuxConf = builtins.readFile ./default.conf + builtins.readFile ./latte.conf;
in {
  home.packages = with pkgs; [
  ];

  programs.tmux = {
    enable = true;
    aggressiveResize = true;
    baseIndex = 1;
    extraConfig = tmuxConf;
    escapeTime = 0;
    keyMode = "vi";
    plugins = with plugins; [
      cpu
      battery
      net-speed
      online-status
      sidebar
      sysstat
      {
        plugin = fingers;
        extraConfig = ''
          set -g @fingers-key F
        '';
      }
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '5' # minutes
        '';
      }
      {
        plugin = resurrect;
        extraConfig = ''
          set -g @resurrect-strategy-vim 'session'
          set -g @resurrect-strategy-nvim 'session'
          set -g @resurrect-capture-pane-contents 'on'
          set -g @resurrect-save 'S'
          set -g @resurrect-restore 'R'
          set -g @resurrect-dir '~/.config/tmux/resurrect'
        '';
      }
    ];
    shortcut = "a";
    terminal = "xterm-256color";
  };
}
