{ config, pkgs, ... }:
let
  networkPkgs = with pkgs; [
    curl                    # A command line tool for transferring files with URL syntax
    dig                     # Domain name server
    networkmanager          # Network configuration and management tool
    networkmanager-openvpn  # NetworkManager's OpenVPN plugin
    openssl                 # Cryptographic library for SSL and TLS protocols
    openvpn                 # A robust and highly flexible tunneling application
    remmina                 # Remote desktop client written in GTK
    termshark               # A terminal UI for wireshark-cli, inspired by Wireshark
    wget                    # Tool for retrieving files using HTTP, HTTPS, and FTP
    wireguard-tools         # Tools for the Wireguard secure network tunnel
    nmap-graphical          # Graphical version of Nmap
   ];
 in
{
}
