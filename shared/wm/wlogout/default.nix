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
    style = ''
          /* Import the base wlogout styles */
      @import "${flavour}.css";
      #lock {
          background-image: url("/home/${username}/.config/wlogout/icons/${theme}/${flavour}/lock.svg");
      }

      #logout {
          background-image: url("/home/${username}/.config/wlogout/icons/${theme}/${flavour}/logout.svg");
      }

      #suspend {
          background-image: url("/home/${username}/.config/wlogout/icons/${theme}/${flavour}/suspend.svg");
      }

      #hibernate {
          background-image: url("/home/${username}/.config/wlogout/icons/${theme}/${flavour}/hibernate.svg");
      }

      #shutdown {
          background-image: url("/home/${username}/.config/wlogout/icons/${theme}/${flavour}/shutdown.svg");
      }

      #reboot {
          background-image: url("/home/${username}/.config/wlogout/icons/${theme}/${flavour}/reboot.svg");
      }
    '';
  };
  home.file.".config/wlogout/${flavour}.css" = {
    source = ./themes/${theme}/${flavour}.css;
    recursive = true;
  };
  home.file.".config/wlogout/icons" = {
    source = ./icons;
    recursive = true;
  };
}
