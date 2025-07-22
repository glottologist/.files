{pkgs, ...}: {
  home.packages = with pkgs; [
    kitty-themes
  ];
  programs.kitty = {
    enable = true;
    package = pkgs.kitty;
    themeFile = "3024_Day";
    settings = {
      font_size = 10;
      font_family = "BerkeleyMono Nerd Font";
      # Matching your Ghostty theme and appearance
      background_opacity = "0.99";
      background_blur = 60;
    };
    extraConfig = ''
    '';
  };
}
