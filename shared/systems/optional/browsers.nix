{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
     brave                  # Privacy-oriented browser for Desktop and Laptop computers
     firefox                # A web browser built from Firefox source tree
     qutebrowser            # Keyboard-focused browser with a minimal GUI
     tor-browser-bundle-bin # Tor Browser Bundle built by torproject.org
     nyxt                   # Infinitely extensible web-browser (with Lisp development files using WebKitGTK platform port)
     chromium               # An open source web browser from Google
     google-chrome          #  A freeware web browser developed by Google
   ];
}
