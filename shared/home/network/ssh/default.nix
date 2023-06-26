{ config, pkgs, ... }:
{
programs.ssh = {
    enable = true;
    extraConfig = /* sshconfig */ ''
      Include config_local
    '';
    matchBlocks = {
       # Home Network ===============================
      "odyssey" = { # pfSense Firewall
        hostname = "10.75.17.1";
        user = "root";
      };
      "deliverance" = {   # Plex Server
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
          user = "root";
        };


  # Additional projects

        "voltaire" = {
          hostname = "ns3163761.ip-51-89-233.eu";
          user = "ubuntu";
        };



  };
};
}
