# Screen sharing and file pickers need a portal on both sessions: the Hyprland
# portal for the wlroots screencopy protocol, the GTK one for everything else.
# Plasma contributes its own portal through desktopManager.plasma6.
{ pkgs, ... }:
{
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal
    ];
    configPackages = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal
    ];
  };
}
