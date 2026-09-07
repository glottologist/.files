# Chimera is a GPD Pocket 3, and the one setting here that is genuinely
# device-specific is the monitor line. The panel is a 1200x1920 OLED on DSI-1,
# mounted rotated ninety degrees, so the compositor has to rotate it back:
# nixos-hardware's gpd/pocket-3 module sets panel_orientation=right_side_up,
# which tells DRM not to correct it, and X11 guidance for this device is
# Option "Rotate" "right".
#
# Hyprland's transform is 1 for ninety degrees and 3 for two hundred and
# seventy. If the desktop comes up inverted on first login, the fix is one
# digit; try it live before editing this file:
#
#   hyprctl keyword monitor DSI-1,1200x1920@60,0x0,1.5,transform,3
#
# The scale of 1.5 is what makes an eight-inch panel at roughly 283 DPI
# legible; Plasma manages its own scaling from System Settings and ignores this.
{
  username = "jrt";
  wallpapers = "bing";

  # Hyprland Settings
  extraMonitorSettings = "monitor=DSI-1,1200x1920@60,0x0,1.5,transform,1";

  # Waybar Settings
  clock24h = true;

  # Program Options
  browser = "zen-browser";
  terminal = "ghostty";
  keyboardLayout = "gb";
  consoleKeyMap = "uk";

  # Set Stylix Image
  stylixImage = ../../secrets/wallpapers/common/glottologist.png;

  # Set Waybar
  # waybar-simple and its siblings read hosts/${host}/variables.nix through a
  # `host` module argument that the home configurations do not pass; this one
  # takes only the standard arguments and therefore evaluates here.
  waybarChoice = ../../shared/wm/waybar/glottologist.nix;

  # Set Animation style
  animChoice = ../../shared/wm/hyprland/animations-end4.nix;
}
