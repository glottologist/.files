{
  config,
  lib,
  pkgs,
  stdenv,
  ...
}:
let
  # AnyDesk pulled the 8.0.2 tarball from their CDN, so the nixpkgs pin fails
  # with a 404. 8.0.3 is the current upstream release; we repin the source and
  # hash until nixpkgs catches up.
  anydesk = pkgs.anydesk.overrideAttrs (_: {
    version = "8.0.3";
    src = pkgs.fetchurl {
      urls = [
        "https://download.anydesk.com/linux/anydesk-8.0.3-amd64.tar.gz"
        "https://download.anydesk.com/linux/generic-linux/anydesk-8.0.3-amd64.tar.gz"
      ];
      hash = "sha256-Mjl17hh5A/pwRAi7giL1SJYlQ61O0SXX+KeH8STZ4bs=";
    };
  });
in {
  home.packages = with pkgs; [
    anydesk # repinned to 8.0.3 in the let above; upstream 404'd 8.0.2
    bmon # Network bandwidth monitor
    gping # Graphical ping
    inetutils # Collection of common network programs
    ipcalc # Simple IP network calculator
    iproute2 # A collection of utilities for controlling TCP/IP networking and traffic control in Linux
    ipscan
    iw # Tool to use nl80211
    linssid # Graphical wireless scanning for Linux
    macchanger # A utility for viewing/manipulating the MAC address of network interfaces
    miraclecast # Connect external monitors via Wi-Fi
    mtr # A network diagnostics tool
    nethogs # A small 'net top' tool, grouping bandwidth by process
    ngrep # Network packet analyzer
    nload # Monitors network traffic and bandwidth usage with ncurses graphs
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
