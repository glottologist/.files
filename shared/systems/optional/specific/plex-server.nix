{ config, pkgs, ... }:

{
  services = {
    plex = {
       enable = true;
       openFirewall = true;
       dataDir = "/railgun/plexserver"
     };
   };
}

