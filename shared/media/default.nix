{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [

      darktable            # Virtual lighttable and darkroom for photographers
      kazam                # A screencasting program created with design in mind
      obs-studio           # Free and open source software for video recording and live streaming
      plex-desktop         # Streaming media player for Plex
      rawtherapee          # RAW converter and digital photo processing software
      simplescreenrecorder # A screen recorder for Linux
      spotify              # Play music from the Spotify music service
      vlc                  # Cross-platform media player and streaming server
      vokoscreen-ng        # Simple GUI screencast recorder, using ffmpeg
  ];
}
