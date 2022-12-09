{ config, lib, pkgs, stdenv, ... }:
{

  imports = [
  ];

  home.packages = with pkgs; [
    adobe-reader                # PDF Reader
    digikam                     # Photo Management Program
    dstask                      # Command line todo list with super-reliable git sync
    electron-mail               # ElectronMail is an Electron-based unofficial desktop client for ProtonMail
    fetchmail                   # Utility to fetch mails locally
    gimp                        # GNU image editor
    hydroxide                   # A third-party, open-source ProtonMail bridge
    inkscape-with-extensions    # Vector graphics editor
    krita                       # A free and open source painting application
    pixeluvo                    # A Beautifully Designed Image and Photo Editor for Windows and Linux
    protonmail-bridge           # Use your ProtonMail account with your local e-mail client
    rainbowstream               # Streaming command-line twitter client
    ultralist                   # Simple GTD-style todo list for the command line
    zk                          # A zettelkasten plain text note-taking assistant
  ];

  programs = {
  };

  services = {
  };
}
