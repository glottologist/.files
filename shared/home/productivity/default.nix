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
    dstask # Command line todo list with super-reliable git sync
    electron-mail # ElectronMail is an Electron-based unofficial desktop client for ProtonMail
    fetchmail # Utility to fetch mails locally
    gimp # GNU image editor
    hydroxide # A third-party, open-source ProtonMail bridge
    inkscape-with-extensions # Vector graphics editor
    krita # A free and open source painting application
    #ntfy-sh # Send push notifications to your phone or desktop via PUT/POST
    ntfy #A utility for sending notifications, on demand and when commands finish:with
    pixeluvo # A Beautifully Designed Image and Photo Editor for Windows and Linux
    protonmail-bridge # Use your ProtonMail account with your local e-mail client
    rainbowstream # Streaming command-line twitter client
    remind # Command line calendar
    ultralist # Simple GTD-style todo list for the command line
    wyrd # A text-based front-end to Remind
    #zk # A zettelkasten plain text note-taking assistant
  ];

  programs = {
  };

  services = {
  };
}
