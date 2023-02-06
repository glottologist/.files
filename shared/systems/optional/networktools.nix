{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    anydesk                 # Desktop sharing application, providing remote support and online meetings
    curl                    # A command line tool for transferring files with URL syntax
    dig                     # Domain name server
    fast-cli                # Test your download and upload speed using fast.com
    gping                   # Graphical ping
    miraclecast             # Connect external monitors via Wi-Fi
    nethogs                 # A small 'net top' tool, grouping bandwidth by process
    networkmanager          # Network configuration and management tool
    networkmanager-openvpn  # NetworkManager's OpenVPN plugin
    ookla-speedtest         # Command line internet speedtest tool by Ookla
    openssl                 # Cryptographic library for SSL and TLS protocols
    openvpn                 # A robust and highly flexible tunneling application
    remmina                 # Remote desktop client written in GTK
    ssh-copy-id             # Copy keys to remote machine
    termshark               # A terminal UI for wireshark-cli, inspired by Wireshark
    vnstat                  # Console-based network statistics utility for Linux
    wget                    # Tool for retrieving files using HTTP, HTTPS, and FTP
    wireguard-tools         # Tools for the Wireguard secure network tunnel
    wifite2                 # Rewrite of the popular wireless network auditor, wifite
  ];
}
