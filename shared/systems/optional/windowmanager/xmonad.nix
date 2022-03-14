{ config, lib, pkgs, ... }:
{
  programs.dconf.enable = true;
  services = {
    gnome.gnome-keyring.enable = true;
    upower.enable = true;
    dbus = {
      enable = true;
      packages = [ pkgs.dconf ];
    };
    xserver = {
      enable = true;
      layout = "gb";
      libinput = {
        enable = true;
        touchpad.disableWhileTyping = true;
      };
      serverLayoutSection = ''
        Option "StandbyTime" "0"
        Option "SuspendTime" "0"
        Option "OffTime"     "0"
      '';
      displayManager = {
        defaultSession = "none+xmonad";
      };
      windowManager.xmonad = {
        enable = true;
        enableContribAndExtras = true;
      };
    };
  };
}
