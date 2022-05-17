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
        hostname = "10.75.79.1";
        user = "root";
      };
      "starbug" = {   # Wireless Access Point
        hostname = "10.75.79.2";
        user = "root";
      };
      "eagle" = {   # Wireless Access Point
        hostname = "10.75.79.3";
        user = "root";
      };
      "gunstar" = {   # Managed Switch
        hostname = "10.75.79.4";
        user = "root";
      };
      "cygnus" = {   # Pi-Hole
        hostname = "10.75.79.4";
        user = "root";
      };
      "swordfish" = {   # Plex Server
        hostname = "10.75.79.10";
        user = "jason";
      };
      "leonov" = {   # Mysterium Node
        hostname = "10.75.79.11";
        user = "jason";
      };
      "valkyrie" = {   # Development
        hostname = "10.75.79.12";
        user = "jason";
      };
      "elysium" = {   # Awair Element
        hostname = "10.75.79.13";
        user = "root";
      };
      "narada" = {   # Bobcat Helium Miner
        hostname = "10.75.79.14";
        user = "root";
      };
      "destiny" = {   # Roku Stremaing Stick
        hostname = "10.75.79.51";
        user = "root";
      };
      "liberator" = {   # Roku Stremaing Stick
        hostname = "10.75.79.52";
        user = "root";
      };
      "bebop" = {   # Jason's NixOS Laptop
        hostname = "10.75.79.101";
        user = "jason";
      };
      "viper" = {   # Jason's Mobile
        hostname = "10.75.79.102";
        user = "root";
      };
      "milano" = {   # Jason's Gear OS Watch
        hostname = "10.75.79.103";
        user = "root";
      };
      "discovery" = {   # Jason's reMarkable
        hostname = "10.75.79.104";
        user = "root";
        extraOptions.PubkeyAcceptedKeyTypes = "+ssh-rsa";
        extraOptions.HostKeyAlgorithms="+ssh-rsa";
      };
      "normandy" = {   # Jason's Kindle
        hostname = "10.75.79.105";
        user = "root";
      };
      "moya" = {   # Kat's Windows Laptop
        hostname = "10.75.79.121";
        user = "kat";
      };
      "tantive" = {   # Kat's Mobile
        hostname = "10.75.79.122";
        user = "root";
      };
      "falcon" = {   # Noah's tablet
        hostname = "10.75.79.131";
        user = "root";
      };
      "prometheus" = {   # Noah's Kindle
        hostname = "10.75.79.132";
        user = "root";
      };
      "firefly" = {   # Isla's tablet
        hostname = "10.75.79.141";
        user = "root";
      };


  #  Hetzner Cloud ======================================
        "ulmo" = {
          hostname = "65.108.244.41";
          user = "root";
        };
        "nessa" = {
          hostname = "78.47.117.138";
          user = "root";
        };
    };
  };

}
