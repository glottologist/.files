{ config, pkgs, ... }:
 transcoding
{
  services = {
    plex = {
       enable = true;
       openFirewall = true;
       dataDir = "/railgun/plex"
     };
   };
}

