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
    #wg-quick.interfaces = {
    #rtwg0 = {
      #address = [ "10.75.13.3/24" ];
      #dns = [ "10.75.13.1" ];
      #privateKeyFile = "/home/jason/wireguard-keys/private";

    #postUp = ''
        #${pkgs.iptables}/bin/iptables -A FORWARD -i rtwg0 -j ACCEPT
        #${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.75.0.0/24 -o eth0 -j MASQUERADE
      #'';

      ## Undo the above
      #preDown = ''
        #${pkgs.iptables}/bin/iptables -D FORWARD -i rtwg0 -j ACCEPT
        #${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.75.0.0/24 -o eth0 -j MASQUERADE
      #'';

      #peers = [
        #{
          #publicKey = "WeeJVyAPczoANEsuOJEHOotroxRyCRXREui96GgXhio=";
          #presharedKeyFile = "/home/jason/wireguard-keys/preshared";
          #allowedIPs = [ "0.0.0.0/0" ];
          #endpoint = "148.113.12.147:48232";
          #persistentKeepalive = 25;
        #}
      #];
    #};
  #};
};
}
