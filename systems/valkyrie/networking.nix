{ config, pkgs, ... }:
{
  networking = {
    hostName = "valkyrie";
    useDHCP = false;
    interfaces.eth0.useDHCP = true;
    #interfaces.wlan0.useDHCP = true;
    networkmanager.enable = true;
    enableIPv6 = false;
    firewall = {
      allowedTCPPorts = [ 6443 3389 ];
      enable = false;
      trustedInterfaces = [ "cni0" ];
    };
    extraHosts = builtins.readFile ../../secrets/hosts;
  };
}
