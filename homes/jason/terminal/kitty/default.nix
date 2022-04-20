{  pkgs, ... }:
{
  programs.kitty = {
    enable = true;
    theme = "PaperColor Light";
    font = {
      name = "FiraCode Nerd Font";
    };
    settings = {
      scrollback_lines = 10000;
      enable_audio_bell = false;
      update_check_interval = 0;
      disable_ligatures = "never";
    };
  };
}
