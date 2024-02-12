{
  config,
  lib,
  pkgs,
  stdenv,
  ...
}: {
  home.packages = with pkgs; [
    amass # In-Depth DNS Enumeration and Network Mapping
    anydesk # Desktop sharing application, providing remote support and online meetings
    bmon # Network bandwidth monitor
    btop # Better version of top
    dig # Domain name server
    fast-cli # Test your download and upload speed using fast.com
    gping # Graphical ping
    inetutils # Collection of common network programs
    ipcalc # Simple IP network calculator
    iproute2 # A collection of utilities for controlling TCP/IP networking and traffic control in Linux
    ipscan # Fast and friendly network scanner
    iw # Tool to use nl80211
    linssid # Graphical wireless scanning for Linux
    macchanger # A utility for viewing/manipulating the MAC address of network interfaces
    miraclecast # Connect external monitors via Wi-Fi
    mtr # A network diagnostics tool
    nethogs # A small 'net top' tool, grouping bandwidth by process
    ngrep # Network packet analyzer
    nload # Monitors network traffic and bandwidth usage with ncurses graphs
    nmap # A free and open source utility for network discovery and security auditing
    noip # Dynamic DNS daemon for no-ip accounts
    ookla-speedtest # Command line internet speedtest tool by Ookla
    remmina # Remote desktop client written in GTK
    teamviewer # Remote access viewer
    termshark # A terminal UI for wireshark-cli, inspired by Wireshark
    vnstat # Console-based network statistics utility for Linux
    wavemon # Ncurses-based monitoring application for wireless network devicesv
    x2goclient # Graphical NoMachine NX3 remote desktop client
  ];

  imports = [
    ../../secrets/ssh.nix
  ];
}
