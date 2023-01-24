{  pkgs, ... }:
{
  home.packages = with pkgs; [
     termpdfpy      # A pdf, epub, cbz reader in the kitty terminal
  ];

  programs.kitty = {
    enable                  = true;
    theme                   = "PaperColor Light";
    font      = {
      name                  = "FiraCode Nerd Font";
    };
    settings  = {
      disable_ligatures     = "never";
      enable_audio_bell     = false;
      scrollback_lines      = 10000;
      shell                 = "${pkgs.fish}/bin/fish";
      update_check_interval = 0;
    };
  };
}
