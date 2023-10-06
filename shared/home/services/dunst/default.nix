{pkgs, ...}: {
  home.packages = with pkgs; [libnotify];

  services.dunst = {
    enable = true;

    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus";
    };

    settings = rec {
      frame = {
        color = "#1E66F5";
      };
      global = {
        alignment = "center";
        allow_markup = true;
        follow = "keyboard";
        font = "Fira Code 10";
        format = ''%a: %s %p\n%b'';
        frame_width = 3;
        geometry = "1870x5-25+45";
        horizontal_padding = 24;
        idle_threshold = 120;
        markup = "full";
        max_icon_size = 128;
        min_icon_size = 32;
        padding = 24;
        separator_color = "#1E66F5";
        separator_height = 5;
        transparency = 5;
        width = 350;
        word_wrap = "yes";
      };
      urgency_critical = {
        background = "#EFF1F5";
        foreground = "#4C4F69";
        frame_color = "#FE640B";
        timeout = 30;
      };

      urgency_low = {
        background = "#EFF1F5";
        foreground = "#4C4F69";

        timeout = 10;
      };

      urgency_normal = {
        background = "#EFF1F5";
        foreground = "#4C4F69";
      };
    };
  };
}
