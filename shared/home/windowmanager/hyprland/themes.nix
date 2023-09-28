{
  config,
  lib,
  pkgs,
  stdenv,
  ...
}: {
  # Config
  xdg.configFile."hypr/themes/neon/theme.conf".source = ./themes/neon/theme.conf;
  xdg.configFile."hypr/themes/neon/theme.toml".source = ./themes/neon/theme.toml;

  # Eww
  ##  Images
  xdg.configFile."eww/images/mic.png".source = ./themes/neon/eww/images/mic.png;
  xdg.configFile."eww/images/music.png".source = ./themes/neon/eww/images/music.png;
  xdg.configFile."eww/images/profile.png".source = ./themes/neon/eww/images/profile.png;
  xdg.configFile."eww/images/speaker.png".source = ./themes/neon/eww/images/speaker.png;
  ##  Scripts
  xdg.configFile."eww/scripts/appname".source = ./themes/neon/eww/scripts/appname;
  xdg.configFile."eww/scripts/battery".source = ./themes/neon/eww/scripts/battery;
  xdg.configFile."eww/scripts/gpu".source = ./themes/neon/eww/scripts/gpu;
  xdg.configFile."eww/scripts/mem-ad".source = ./themes/neon/eww/scripts/mem-ad;
  xdg.configFile."eww/scripts/memory".source = ./themes/neon/eww/scripts/memory;
  xdg.configFile."eww/scripts/music".source = ./themes/neon/eww/scripts/music;
  xdg.configFile."eww/scripts/music_info".source = ./themes/neon/eww/scripts/music_info;
  xdg.configFile."eww/scripts/notifications".source = ./themes/neon/eww/scripts/notifications;
  xdg.configFile."eww/scripts/pop".source = ./themes/neon/eww/scripts/pop;
  xdg.configFile."eww/scripts/sbvol".source = ./themes/neon/eww/scripts/sbvol;
  xdg.configFile."eww/scripts/weather".source = ./themes/neon/eww/scripts/weather;
  xdg.configFile."eww/scripts/wifi".source = ./themes/neon/eww/scripts/wifi;
  xdg.configFile."eww/scripts/workspace".source = ./themes/neon/eww/scripts/workspace;
  ##  Config
  xdg.configFile."eww/eww.scss".source = ./themes/neon/eww/eww.scss;
  xdg.configFile."eww/eww.yuck".source = ./themes/neon/eww/eww.yuck;
  xdg.configFile."eww/favicon.ico".source = ./themes/neon/eww/favicon.ico;
  xdg.configFile."eww/launch_bar".source = ./themes/neon/eww/launch_bar;
  xdg.configFile."eww/notifications.yuck".source = ./themes/neon/eww/notifications.yuck;
  xdg.configFile."eww/sidebar.yuck".source = ./themes/neon/eww/sidebar.yuck;

  # Rofi
  ##  Config
  xdg.configFile."hypr/themes/neon/rofi/launcher.rasi".source = ./themes/neon/rofi/launcher.rasi;
  xdg.configFile."hypr/themes/neon/rofi/list_launcher.rasi".source = ./themes/neon/rofi/list_launcher.rasi;
  xdg.configFile."hypr/themes/neon/rofi/powermenu.rasi".source = ./themes/neon/rofi/powermenu.rasi;
  xdg.configFile."hypr/themes/neon/rofi/powermenu.sh".source = ./themes/neon/rofi/powermenu.sh;
  ##  Global
  xdg.configFile."hypr/themes/neon/rofi/global/rofi-spotlight.sh".source = ./themes/neon/rofi/global/rofi-spotlight.sh;
  xdg.configFile."hypr/themes/neon/rofi/global/rofi.rasi".source = ./themes/neon/rofi/global/rofi.rasi;
  xdg.configFile."hypr/themes/neon/rofi/global/web-search.py".source = ./themes/neon/rofi/global/web-search.py;
  ### Icons
  xdg.configFile."hypr/themes/neon/rofi/global/icons/ddg.svg".source = ./themes/neon/rofi/global/icons/ddg.svg;
  xdg.configFile."hypr/themes/neon/rofi/global/icons/google.svg".source = ./themes/neon/rofi/global/icons/google.svg;
  xdg.configFile."hypr/themes/neon/rofi/global/icons/history.svg".source = ./themes/neon/rofi/global/icons/history.svg;
  xdg.configFile."hypr/themes/neon/rofi/global/icons/result.svg".source = ./themes/neon/rofi/global/icons/result.svg;
  xdg.configFile."hypr/themes/neon/rofi/global/icons/suggestion.svg".source = ./themes/neon/rofi/global/icons/suggestion.svg;
  # Scripts
  xdg.configFile."hypr/themes/neon/scripts/default_app".source = ./themes/neon/scripts/default_app;
  xdg.configFile."hypr/themes/neon/scripts/flicker".source = ./themes/neon/scripts/flicker;
  xdg.configFile."hypr/themes/neon/scripts/swwwpaper".source = ./themes/neon/scripts/swwwpaper;
  xdg.configFile."hypr/themes/neon/scripts/wallpaper".source = ./themes/neon/scripts/wallpaper;
  xdg.configFile."hypr/themes/neon/scripts/workspace".source = ./themes/neon/scripts/workspace;
}
