{
  config,
  username,
  ...
}: let
  theme = "latte";
  flavour = "lavender";
in {
  programs.wlogout = {
    enable = true;
    layout = [
      {
        label = "shutdown";
        action = "sleep 1; systemctl poweroff";
        text = "Shutdown (s)";
        keybind = "s";
      }
      {
        "label" = "reboot";
        "action" = "sleep 1; systemctl reboot";
        "text" = "Reboot (r)";
        "keybind" = "r";
      }
      {
        "label" = "logout";
        "action" = "sleep 1; hyprctl dispatch exit";
        "text" = "Logout (e)";
        "keybind" = "e";
      }
      {
        "label" = "suspend";
        "action" = "sleep 1; systemctl suspend";
        "text" = "Suspend (u)";
        "keybind" = "u";
      }
      {
        "label" = "lock";
        "action" = "sleep 1; hyprlock";
        "text" = "Lock (l)";
        "keybind" = "l";
      }
      {
        "label" = "hibernate";
        "action" = "sleep 1; systemctl hibernate";
        "text" = "Hibernate (h)";
        "keybind" = "h";
      }
    ];
    style = "";
  };
  # Create main CSS file with theme and icon definitions
  home.file.".config/wlogout/main.css" = {
    source = ./theme.css;
    recursive = true;
  };

  # Copy theme CSS file
  home.file.".config/wlogout/theme.css" = {
    source = ./themes/${theme}/${flavour}.css;
    recursive = true;
  };

  # Copy icon files
  home.file.".config/wlogout/icons" = {
    source = ./icons/${theme}/${flavour};
    recursive = true;
  };
}
