{
  config,
  lib,
  pkgs,
  ...
}: {
  #environment.systemPackages = with pkgs.plasma5Packages; [
  #];

  programs.dconf.enable = true;
  services = {
    gnome.gnome-keyring.enable = true;
    upower.enable = true;
    dbus = {
      enable = true;
      packages = [pkgs.dconf];
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
      displayManager.lightdm.enable = true;
      desktopManager.plasma5.enable = true;
    };
  };
}
