
{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    dig                     # Domain name server
    curl                    # A command line tool for transferring files with URL syntax
    networkmanager          # Network configuration and management tool
    networkmanager-openvpn  # NetworkManager's OpenVPN plugin
    openssl                 # Cryptographic library for SSL and TLS protocols
    openvpn                 # A robust and highly flexible tunneling application
    termshark               # A terminal UI for wireshark-cli, inspired by Wireshark
    wireguard-tools         # Tools for the Wireguard secure network tunnel
    wget                    # Tool for retrieving files using HTTP, HTTPS, and FTP
   ];
}
