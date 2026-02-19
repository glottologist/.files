{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  environment.systemPackages = with pkgs; [networkmanagerapplet];
  networking = {
    hostName = "bebop"; # Define your hostname.
    networkmanager = {
      enable = true;
      wifi.powersave = false; # Prevent periodic wifi disconnections
      dns = "systemd-resolved";
    };
    useDHCP = lib.mkDefault true;
    extraHosts = builtins.readFile ../../secrets/hosts;
  };

  # Enable systemd-resolved with DNS-over-TLS for Quad9
  services.resolved = {
    enable = true;
    dnssec = "allow-downgrade";
    domains = [ "~." ];
    fallbackDns = [ "9.9.9.9" "149.112.112.112" ];
    extraConfig = ''
      DNSOverTLS=opportunistic
      DNS=9.9.9.9#dns.quad9.net 149.112.112.112#dns.quad9.net
      [2620:fe::fe]#dns.quad9.net [2620:fe::9]#dns.quad9.net
    '';
  };
}
