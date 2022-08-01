{ config, lib, pkgs, stdenv, ... }:
{

  imports = [
  ];

  home.packages = with pkgs; [
    dstask                      # Command line todo list with super-reliable git sync
    rainbowstream               # Streaming command-line twitter client
    adobe-reader                # PDF Reader
    gimp                        # GNU image editor
    krita                       # A free and open source painting application
    digikam                     # Photo Management Program
    pixeluvo                    # A Beautifully Designed Image and Photo Editor for Windows and Linux
    inkscape-with-extensions    # Vector graphics editor
    protonmail-bridge           # Use your ProtonMail account with your local e-mail client
    hydroxide                   # A third-party, open-source ProtonMail bridge
    electron-mail               # ElectronMail is an Electron-based unofficial desktop client for ProtonMail
  ];

  programs = {
  };

  services = {
  };
}
