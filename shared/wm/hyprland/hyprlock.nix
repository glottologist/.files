{username, ...}: {
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = true;
        grace = 10;
        hide_cursor = true;
        no_fade_in = false;
      };
      background = [
        {
          path = "/home/${username}/Pictures/Wallpapers/beautifulmountainscape.jpg";
          blur_passes = 3;
          blur_size = 8;
        }
      ];
      image = [
        {
          path = "/home/${username}/.config/face.jpg";
          size = 150;
          border_size = 4;
          border_color = "rgb(30, 102, 245)"; # Catppuccin Latte Blue (#1e66f5)
          rounding = -1; # Negative means circle
          position = "0, 200";
          halign = "center";
          valign = "center";
        }
      ];
      input-field = [
        {
          size = "300, 60";
          position = "0, -80";
          monitor = "";
          dots_center = true;
          fade_on_empty = false;
          font_color = "rgb(76, 79, 105)";        # Catppuccin Latte Text (#4c4f69)
          inner_color = "rgb(239, 241, 245)";     # Catppuccin Latte Base (#eff1f5)
          outer_color = "rgb(220, 224, 232)";     # Catppuccin Latte Crust (#dce0e8)
          outline_thickness = 3;
          placeholder_text = "Enter Password...";
          shadow_passes = 2;
          shadow_color = "rgb(188, 192, 204)";    # Catppuccin Latte Surface1 (#bcc0cc)
          
          # Password-only authentication
          hide_input = false;
          dots_spacing = 0.15;
          dots_rounding = -1; # Circle dots
          
          # Enhanced styling for light theme
          check_color = "rgb(64, 160, 43)";       # Catppuccin Latte Green (#40a02b)
          fail_color = "rgb(210, 15, 57)";        # Catppuccin Latte Red (#d20f39)
          capslock_color = "rgb(254, 100, 11)";   # Catppuccin Latte Peach (#fe640b)
          numlock_color = "rgb(136, 57, 239)";    # Catppuccin Latte Mauve (#8839ef)
          
          # Positioning and behavior
          halign = "center";
          valign = "center";
          
          # Input field behavior
          fail_text = "Authentication Failed";
          fail_timeout = 2000; # 2 seconds
          fail_transition = 300; # 300ms transition
        }
      ];
      
      # Optional: Add a label for better UX
      label = [
        {
          text = "Welcome back, ${username}";
          color = "rgb(76, 79, 105)"; # Catppuccin Latte Text
          font_size = 25;
          font_family = "JetBrainsMono Nerd Font";
          position = "0, 120";
          halign = "center";
          valign = "center";
        }
        {
          text = "$TIME";
          color = "rgb(92, 95, 119)"; # Catppuccin Latte Subtext1
          font_size = 55;
          font_family = "JetBrainsMono Nerd Font";
          position = "0, 300";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };
}
