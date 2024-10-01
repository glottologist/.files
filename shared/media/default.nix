{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [

      darktable            # Virtual lighttable and darkroom for photographers
      obs-studio           # Free and open source software for video recording and live streaming
      plex-media-player    # Streaming media player for Plex
      spotify              # Play music from the Spotify music service
      vlc                  # Cross-platform media player and streaming server
      ffmpeg_5             # A complete, cross-platform solution to record, convert and stream audio and video
      simplescreenrecorder # A screen recorder for Linux
      vokoscreen-ng        # Simple GUI screencast recorder, using ffmpeg
      kazam                # A screencasting program created with design in mind

  ];
}
