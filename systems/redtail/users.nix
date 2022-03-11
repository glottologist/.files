{ config, pkgs, ... }:
{
   users.users.jason = {
     isNormalUser = true;
     extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
   };


}

