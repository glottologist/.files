# Plasma 6 for the Hetzner agent desktops. The no-suspend policy matters
# because a cloud guest that suspends is a cloud guest we cannot reach.
{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.foot
    pkgs.ghostty
    pkgs.kitty
  ];

  services = {
    xserver = {
      enable = true;
      xkb = {
        layout = "gb";
        variant = "";
      };
    };
    displayManager.sddm.enable = true;
    desktopManager.plasma6.enable = true;
    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    logind.settings.Login = {
      HandleLidSwitch = "ignore";
      HandleSuspendKey = "ignore";
      HandleHibernateKey = "ignore";
      IdleAction = "ignore";
    };
  };

  security.rtkit.enable = true;

  systemd = {
    targets = {
      sleep.enable = false;
      suspend.enable = false;
      hibernate.enable = false;
      hybrid-sleep.enable = false;
    };
    sleep.settings.Sleep = {
      AllowSuspend = "no";
      AllowHibernation = "no";
      AllowHybridSleep = "no";
      AllowSuspendThenHibernate = "no";
    };
  };

  # Plasma idles to suspend by default, which would strand an RDP session.
  environment.etc."xdg/powerdevilrc".text = ''
    [AC][SuspendSession]
    IdleTimeout=0
    SuspendType=0

    [Battery][SuspendSession]
    IdleTimeout=0
    SuspendType=0

    [LowBattery][SuspendSession]
    IdleTimeout=0
    SuspendType=0
  '';
}
