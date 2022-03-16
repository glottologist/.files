{ config, pkgs, ... }:

{
  networking = {
    hostName = "swordfish";
    useDHCP = false;
    interfaces.eth0.useDHCP = true;
    #interfaces.wlan0.useDHCP = true;
    networkmanager.enable = true;
    enableIPv6 = false;
    firewall = {
      enable = false;
    };
    extraHosts = builtins.readFile ../../secrets/hosts;

  };
}
