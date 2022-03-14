{ config, pkgs, ... }:
{
  environment = {
   systemPackages = with pkgs; [
     cachix                  # Command line client for Nix binary cache hosting
     curl                    # A command line tool for transferring files
     dig                     # Domain name server
     diskonaut               # Termainal disk space navigator
     parted                  # Command line partition tool
     lethe                   # Tool to wipe drives in a particular
     ntfs3g                  # FUSE based NTFS driver
     openssl                 # Cryptographic library for SSL and TLS protocols
     openvpn                 # A robust and highly flexible tunneling application
     tree                    # Depth indented directory listing
     wget
   ];
 };
}
