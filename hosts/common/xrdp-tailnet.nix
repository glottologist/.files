# RDP reachable over the Headscale tailnet and nowhere else.
#
# openFirewall stays false so that importing this module can never by itself
# expose 3389 to the public interface. The port is admitted on tailscale0
# alone. The restriction is enforced here rather than by binding the daemon
# because services.xrdp has no listen-address option, and the tailnet address
# is assigned at runtime by Headscale and so cannot be written down.
{ config, ... }:
{
  services.xrdp = {
    enable = true;
    defaultWindowManager = "startplasma-x11";
    openFirewall = false;
  };

  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [
    config.services.xrdp.port
  ];
}
