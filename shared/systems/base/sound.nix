{ config, pkgs, ... }:
{
  environment = {
   systemPackages = with pkgs; [
     pavucontrol  # PulseAudio Volume Control
   ];
 };
   sound = {
      enable = true;
      mediaKeys = {
        enable = true;
      };
   };
}
