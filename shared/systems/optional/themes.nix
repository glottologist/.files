{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
     adapta-kde-theme
     adementary-theme
     amber-theme
     ant-nebula-theme
     ant-theme
     mojave-gtk-theme
     nordic
   ];
}
