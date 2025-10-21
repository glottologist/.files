{
  config,
  lib,
  pkgs,
  stdenv,
  ...
}: {
  xdg.configFile."fish/functions/airplane_mode_toggle.fish".source = ./functions/airplane_mode_toggle.fish;
  xdg.configFile."fish/functions/alert.fish".source = ./functions/alert.fish;
  xdg.configFile."fish/functions/bluetooth_toggle.fish".source = ./functions/bluetooth_toggle.fish;
  xdg.configFile."fish/functions/check_airplane_mode.fish".source = ./functions/check_airplane_mode.fish;
  xdg.configFile."fish/functions/dunst_pause.fish".source = ./functions/dunst_pause.fish;
  xdg.configFile."fish/functions/fish_greeting.fish".source = ./functions/fish_greeting.fish;
  xdg.configFile."fish/functions/git_worktree_create.fish".source = ./functions/git_worktree_create.fish;
  xdg.configFile."fish/functions/git_worktree_remove_matching.fish".source = ./functions/git_worktree_remove_matching.fish;
  xdg.configFile."fish/functions/jj_track_bookmark.fish".source = ./functions/jj_track_bookmark.fish;
  xdg.configFile."fish/functions/pr_worktree.fish".source = ./functions/pr_worktree.fish;
  xdg.configFile."fish/functions/rgmatch.fish".source = ./functions/rgmatch.fish;
  xdg.configFile."fish/functions/sync_directories.fish".source = ./functions/sync_directories.fish;
  xdg.configFile."fish/functions/uz.fish".source = ./functions/uz.fish;
  xdg.configFile."fish/functions/wifi_monitor.fish".source = ./functions/wifi_monitor.fish;
  xdg.configFile."fish/functions/wifi_toggle.fish".source = ./functions/wifi_toggle.fish;
  xdg.configFile."fish/functions/wifi_watch.fish".source = ./functions/wifi_watch.fish;
}
