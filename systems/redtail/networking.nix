{ config, pkgs, ... }:
{
  networking = {
    hostName = "redtail";
    useDHCP = false;
    interfaces = {
      enp0s3.useDHCP = true;
    };
  };

}
