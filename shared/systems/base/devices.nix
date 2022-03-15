{ config, pkgs, ... }:
{
  environment = {
   systemPackages = with pkgs; [
     hidapi                  # Library for communicating with USB and Bluetooth HID devices
   ];
 };
}
