{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [

      cliamp               # Terminal Winamp - retro terminal music player
      darktable            # Virtual lighttable and darkroom for photographers
      kazam                # A screencasting program created with design in mind
      goodvibes            # Lightweight internet radio player, headless behind the Omnixy media panel
      gpu-screen-recorder-gtk # GPU-accelerated screen recorder GUI
      obs-studio           # Free and open source software for video recording and live streaming
      plex-desktop         # Streaming media player for Plex
      rawtherapee          # RAW converter and digital photo processing software
      shortwave            # Browse the radio-browser.info database and find new stations
      simplescreenrecorder # A screen recorder for Linux
      spotify              # Play music from the Spotify music service
      vlc                  # Cross-platform media player and streaming server
      vokoscreen-ng        # Simple GUI screencast recorder, using ffmpeg
  ];
}
