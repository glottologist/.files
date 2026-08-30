{username, ...}: let
  inherit (import ../../../homes/${username}/variables.nix) waybarChoice;
in {
  imports = [
    waybarChoice
    ../hyprland/default.nix
    ../rofi/default.nix
    ../scripts/default.nix
    ../wlogout/default.nix
  ];

  # waybar, hypridle and dunst default to graphical-session.target, which
  # Plasma also reaches; hyprland-session.target is started only by the
  # exec-once that Home Manager adds to hyprland.conf.
  wayland.systemd.target = "hyprland-session.target";
}
