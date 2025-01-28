{
  config,
  lib,
  pkgs,
  stdenv,
  ...
}: {
  imports = [
  ];

  home.packages = with pkgs; [
    adobe-reader # PDF Reader
    digikam # Photo Management Program
    dosage # A comic strip downloader and archiver
    dstask # Command line todo list with super-reliable git sync
    electron-mail # ElectronMail is an Electron-based unofficial desktop client for ProtonMail
    fetchmail # Utility to fetch mails locally
    #frostwire #BitTorrent Client and Cloud File Downloader
    gimp # GNU image editor
    hydroxide # A third-party, open-source ProtonMail bridge
    inkscape-with-extensions # Vector graphics editor
    krita # A free and open source painting application
    motrix # A full-featured download manager
    ntfy-sh # Send push notifications to your phone or desktop via PUT/POST
    #ntfy #A utility for sending notifications, on demand and when commands finish:with
    persepolis # Persepolis Download Manager is a GUI for aria2
    pixeluvo # A Beautifully Designed Image and Photo Editor for Windows and Linux
    protonmail-bridge # Use your ProtonMail account with your local e-mail client
    qalculate-qt # The ultimate desktop calculator
    rainbowstream # Streaming command-line twitter client
    ultralist # Simple GTD-style todo list for the command line
    wyrd # A text-based front-end to Remind
    youtube-dl # Command line video downloader
    youtube-tui # YouTube TUI
    tartube # A GUI front end for youtube-dl
    clipgrab # Video download for YouTube
    yt-dlp
  ];

  programs = {
  };

  services = {
  };
}
