{ config, pkgs, ... }:

{
  networking = {
    hostName = "bebop";
    useDHCP = false;
    interfaces = {
      wlp0s20f3.useDHCP = true;
    };
    networkmanager.enable = true;
    nat = {
      enable = true;
      externalInterface = "eth0";
      internalInterfaces = [ "wg0" ];
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
