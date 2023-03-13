{ config, pkgs, ... }:

{
  networking = {
    hostName = "bebop";
    useDHCP = false;
    #interfaces.wlp0s20f3.useDHCP = true;
    interfaces.wlan0.useDHCP = true;
    #wireless.iwd.enable = true;
    networkmanager = {
      enable = true;
      #wifi.backend = "iwd";
    };
    nat = {
      enable = true;
      externalInterface = "eth0";
    };
    firewall = {
      enable = false;
      allowedTCPPortRanges = [
        { from = 1714; to = 1764; }
      ];
      allowedTCPPorts = [ 17500 51820 ];
      allowedUDPPorts = [ 17500 51820 ];
    };

    extraHosts = builtins.readFile ../../secrets/hosts;

  };
}
