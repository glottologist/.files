{lib, ...}: let
  thermald-conf = ./thermald-conf.xml;
in {
  # This will save you money and possibly your life!
  services = {
    thermald = {
      enable = lib.mkDefault true;
      configFile = lib.mkDefault thermald-conf;
    };
    fstrim.enable = lib.mkDefault true;
    hdapsd.enable = lib.mkDefault true;
    printing.enable = true;
    dbus.enable = true;
    acpid.enable = true;
    upower.enable = true;
    #tlp.enable = true;
    kubo = {
      enable = true;
      settings.Addresses.API = ["/ip4/127.0.0.1/tcp/5001"];
    };
    blueman.enable = true;
    #dnsmasq = {
    #enable = true;
    #extraConfig = ''
    #interface=rtwg0
    #'';
    #};
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
