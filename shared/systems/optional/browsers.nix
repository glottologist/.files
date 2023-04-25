{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
     brave                  # Privacy-oriented browser for Desktop and Laptop computers
     firefox                # A web browser built from Firefox source tree
     qutebrowser            # Keyboard-focused browser with a minimal GUI
     tor-browser-bundle-bin # Tor Browser Bundle built by torproject.org

   ];
}
