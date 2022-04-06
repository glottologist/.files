{ config, pkgs, ... }:

let
  plugins  = pkgs.tmuxPlugins // pkgs.callPackage ./plugins.nix {};
  tmuxConf = builtins.readFile ./default.conf;
in
{
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
       tmux-cssh
       tpm
       {
         plugin = pomodoro;
         extraConfig = ''
            set -g @pomodoro_duration 25
            set -g @pomodoro_fg_color 'red'
            set -g @pomodoro_bg_color 'blue'
            set -g @pomodoro_show_clock 'on_stop'
        '';
       }
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
    terminal = "screen-256color";
  };
}
