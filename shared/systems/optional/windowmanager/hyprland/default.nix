{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    eww
    dunst
    libnotify
    swww
    wayland-protocols
    wayland-utils
    wlroots
    rofi-wayland
    xdg-desktop-portal-gtk
    xdg-desktop-portal-hyprland
    xdg-utils
    xwayland
    meson
  ];
  environment.sessionVariables = {
    IXOS_OZONE_WL = "1";
  };

  programs.hyprland = {
    enable = true;
    xwayland.hidpi = true;
    xwayland.enable = true;
    #package = inputs.hyprland.packages.${pkgs.system}.hyprland;
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
  };
}