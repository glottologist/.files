{ config, lib, pkgs, stdenv, ... }:

{

  home.packages = with pkgs; [
    amass         # In-Depth DNS Enumeration and Network Mapping
    bmon          # Network bandwidth monitor
    btop          # Better version of top
    inetutils     # Collection of common network programs
    ipcalc        # Simple IP network calculator
    iproute2      # A collection of utilities for controlling TCP/IP networking and traffic control in Linux
    ipscan        # Fast and friendly network scanner
    macchanger    # A utility for viewing/manipulating the MAC address of network interfaces
    mtr           # A network diagnostics tool
    ngrep         # Network packet analyzer
    nload         # Monitors network traffic and bandwidth usage with ncurses graphs
    nmap          # A free and open source utility for network discovery and security auditing
  ];

  imports = [
    ./ssh/default.nix

  ];

}
