# Hetzner hands out both the public address on eth0 and the private
# 10.79.93.0/24 address on enp7s0 over DHCP. Only SSH is public; RDP is
# admitted on tailscale0 by ../common/xrdp-tailnet.nix.
{ lib, ... }:
{
  networking = {
    hostName = "defiant";
    useDHCP = lib.mkDefault true;
    firewall.enable = true;
    firewall.allowedTCPPorts = [ 22 ];
  };

  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";
  console.keyMap = "uk";
}
