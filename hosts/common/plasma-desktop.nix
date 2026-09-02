# Plasma 6 for the Hetzner agent desktops. The no-suspend policy matters
# because a cloud guest that suspends is a cloud guest we cannot reach.
{ ... }:
{
  services.xserver.enable = true;
  services.xserver.xkb = {
    layout = "gb";
    variant = "";
  };
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  systemd.sleep.settings.Sleep = {
    AllowSuspend = "no";
    AllowHibernation = "no";
    AllowHybridSleep = "no";
    AllowSuspendThenHibernate = "no";
  };

  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleSuspendKey = "ignore";
    HandleHibernateKey = "ignore";
    IdleAction = "ignore";
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
