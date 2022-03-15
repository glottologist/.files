{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
      darktable           # Virtual lighttable and darkroom for photographers
      obs-studio          # Free and open source software for video recording and live streaming
      plex-media-player   # Streaming media player for Plex
      spotify             # Play music from the Spotify music service
      spotify-tui         # Spotify for the terminal written in Rust
      vlc                 # Cross-platform media player and streaming server
   ];
}
