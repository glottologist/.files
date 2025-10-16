{
  username = "glottologist";
  wallpapers = "bebop";

  # Hyprland Settings
  extraMonitorSettings = "monitor=Virtual-1,1920x1080@75,auto,1";

  # Waybar Settings
  clock24h = true;

  # Program Options
  browser = "brave"; # Set Default Browser (google-chrome-stable for google-chrome)
  terminal = "kitty"; # Set Default System Terminal
  keyboardLayout = "gb";
  consoleKeyMap = "uk";
  # For Nvidia Prime support
  intelID = "PCI:1:0:0";
  nvidiaID = "PCI:0:2:0";

  # Enable NFS
  enableNFS = true;

  # Enable Printing Support
  printEnable = false;

  # Set Stylix Image
  stylixImage = ../../secrets/wallpapers/Common/glottologist.png;

  # Set Waybar
  # Available options:
  waybarChoice = ../../shared/wm/waybar/glottologist.nix;

  # Set Animation style
  animChoice = ../../shared/wm/hyprland/animations-end4.nix;

  # Enable Thunar GUI File Manager
  thunarEnable = true;
}
