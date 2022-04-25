{ config, pkgs, ... }:
{
   users.users.jason = {
     isNormalUser = true;
     extraGroups = [ "wheel" "networkmanager" "docker" "plugdev" "libvirt" "pulse" "audio" ];
     openssh.authorizedKeys.keys = [
         "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILN1szb/fBxMMUgpClXaFd4zR71B5/02Ij9jV4wxKW+o jason@glottologist.co.uk"
     ];
   };
}

