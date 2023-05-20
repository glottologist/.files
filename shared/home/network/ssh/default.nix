{ config, pkgs, ... }:
{
programs.ssh = {
    enable = true;
    extraConfig = /* sshconfig */ ''
      Include config_local
    '';
    matchBlocks = {
       # Home Network ===============================
      "serenity" = {  # Protectli VM
        hostname = "192.168.1.68";
        user = "root";
      };
      "odyssey" = { # pfSense Firewall
        hostname = "10.75.17.1";
        user = "root";
      };
      "starbug" = {   # Wireless Access Point
        hostname = "10.75.17.2";
        user = "root";
      };
      "eagle" = {   # Wireless Access Point
        hostname = "10.75.17.3";
        user = "root";
      };
      "gunstar" = {   # Managed Switch
        hostname = "10.75.17.4";
        user = "root";
      };
      "cygnus" = {   # Pi-Hole
        hostname = "10.75.17.5";
        user = "root";
      };
      "swordfish" = {   # Plex Server
        hostname = "10.75.17.10";
        user = "jason";
      };

  #  Hetzner Cloud - Glottologist ======================================
        "valiant" = {
          hostname = "65.108.61.76";
          user = "jason";
        };

        "tantive" = {
          hostname = "135.181.148.161";
          user = "root";
        };

  #  Hetzner Cloud - Ontologi ======================================
        "mercury" = {
          hostname = "5.161.145.173";
          user = "root";
        };
        "olorin" = {
          hostname = "167.235.226.45";
          user = "root";
        };
        "morgoth" = {
          hostname = "135.181.81.37";
          user = "root";
        };
        "curunir" = {
          hostname = "65.109.1.74";
          user = "root";
        };


  # OVH
        "hermes" = {
          hostname = "198.244.229.218";
          user = "debian";
        };
        "athena" = {
          hostname = "148.113.6.10";
          user = "debian";
        };
  };
};
}
