{ lib, ... }:
let
 thermald-conf = ./thermald-conf.xml;
in
{
  # This will save you money and possibly your life!
  services = {
    thermald = {
      enable = lib.mkDefault true;
      configFile = lib.mkDefault thermald-conf;
    };
    fstrim.enable = lib.mkDefault true;
  };
}
