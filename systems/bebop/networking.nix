{ config, pkgs, ... }:

{
  networking = {
    hostName = "bebop";
    useDHCP = false;
    interfaces.wlp0s20f3.useDHCP = true;
    #wireless.enable = true;
    networkmanager = {
      enable = true;
      #unmanaged = [
           #"*" "except:type:wwan" "except:type:gsm"
      #];
      dispatcherScripts = [
       {
        source = (pkgs.writeShellApplication {
          name = "link_change.sh";
          runtimeInputs = [ pkgs.networkmanager ];
          text = ''
            logger "$0" "$@"
          '';
        }).out + "/bin/" + "link_change.sh";
       }
      ];
    };
    nat = {
      enable = true;
      externalInterface = "eth0";
      #internalInterfaces = [ "wg0" ];
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
