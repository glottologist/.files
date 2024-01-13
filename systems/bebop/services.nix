{
  lib,
  pkgs,
  ...
}: let
  thermald-conf = ./thermald-conf.xml;
in {
  # This will save you money and possibly your life!
  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal"; # Without this errors will spam on screen
    # Without these bootlogs will spam on screen
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
  };

  services = {
  teamviewer.enable = true;
    greetd = let
      session = {
        command = "${pkgs.hyprland}/bin/Hyprland";
        user = "jason";
      };
    in {
      enable = true;
      settings = {
        terminal.vt = 1;
        default_session = session;
        initial_session = session;
      };
    };

    gnome = {
      gnome-keyring.enable = true;
    };
    thermald = {
      enable = lib.mkDefault true;
      configFile = lib.mkDefault thermald-conf;
    };
    fstrim.enable = lib.mkDefault true;
    hdapsd.enable = lib.mkDefault true;
    printing.enable = true;
    dbus = {
      enable = true;
      packages = with pkgs; [
        gnome.gnome-keyring
        gcr
      ];
    };
    udisks2.enable = true;
    acpid.enable = true;
    upower.enable = true;
    kubo = {
      enable = true;
      settings.Addresses.API = ["/ip4/127.0.0.1/tcp/5001"];
    };
    blueman.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      jack.enable = true;
    };
  };
}
