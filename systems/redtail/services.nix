{ config, pkgs, ... }:
{
  # Enable the X11 windowing system.
  services =  {
    xserver = {
      enable = true;
      displayManager.sddm.enable = true;
      desktopManager.plasma5.enable = true;
    };
  };
}

