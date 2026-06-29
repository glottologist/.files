{username, ...}: let
  inherit
    (import ../../../homes/${username}/variables.nix)
    extraMonitorSettings
    ;
in {
  wayland.windowManager.hyprland = {
    settings = {
      # Hyprland 0.55 hyprlang syntax: matchers use the `match:<prop> <value>`
      # form, effects use `<effect> <value>` (booleans need an explicit `on`),
      # both comma-separated. Rules evaluate top to bottom, so order matters:
      # tag-assignment rules must precede rules that match on those tags.
      windowrule = [
        "match:class ^([Tt]hunar|org.gnome.Nautilus|[Pp]cmanfm-qt)$, tag +file-manager"
        "match:class ^(com.mitchellh.ghostty|org.wezfurlong.wezterm|Alacritty|kitty|kitty-dropterm)$, tag +terminal"
        "match:class ^(Brave-browser(-beta|-dev|-unstable)?)$, tag +browser"
        "match:class ^([Ff]irefox|org.mozilla.firefox|[Ff]irefox-esr)$, tag +browser"
        "match:class ^([Gg]oogle-chrome(-beta|-dev|-unstable)?)$, tag +browser"
        "match:class ^([Tt]horium-browser|[Cc]achy-browser)$, tag +browser"
        "match:class ^(codium|codium-url-handler|VSCodium)$, tag +projects"
        "match:class ^(VSCode|code-url-handler)$, tag +projects"
        "match:class ^([Dd]iscord|[Ww]ebCord|[Vv]esktop)$, tag +im"
        "match:class ^([Ff]erdium)$, tag +im"
        "match:class ^([Ww]hatsapp-for-linux)$, tag +im"
        "match:class ^(org.telegram.desktop|io.github.tdesktop_x64.TDesktop)$, tag +im"
        "match:class ^(teams-for-linux)$, tag +im"
        "match:class ^(gamescope)$, tag +games"
        "match:class ^([Ss]team)$, tag +gamestore"
        "match:title ^([Ll]utris)$, tag +gamestore"
        "match:class ^(com.heroicgameslauncher.hgl)$, tag +gamestore"
        "match:class ^(gnome-disks|wihotspot(-gui)?)$, tag +settings"
        "match:class ^([Rr]ofi)$, tag +settings"
        "match:class ^(file-roller|org.gnome.FileRoller)$, tag +settings"
        "match:class ^(nm-applet|nm-connection-editor|blueman-manager)$, tag +settings"
        "match:class ^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol)$, tag +settings"
        "match:class ^(nwg-look|qt5ct|qt6ct|[Yy]ad)$, tag +settings"
        "match:class (xdg-desktop-portal-gtk), tag +settings"
        "match:class (.blueman-manager-wrapped), tag +settings"
        "match:class (nwg-displays), tag +settings"
        "match:title ^(Picture-in-Picture)$, move 72% 7%"
        "match:class ^([Ff]erdium)$, center on"
        "match:class ^([Ww]aypaper)$, float on"
        "match:class ^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol)$, center on"
        "match:class ([Tt]hunar), match:title negative:(.*[Tt]hunar.*), center on"
        "match:title ^(Authentication Required)$, center on"
        "match:class ^(*)$, idle_inhibit fullscreen"
        "match:title ^(*)$, idle_inhibit fullscreen"
        "match:fullscreen true, idle_inhibit fullscreen"
        "match:tag settings, float on"
        "match:class ^([Ff]erdium)$, float on"
        "match:title ^(Picture-in-Picture)$, float on"
        "match:class ^(mpv|com.github.rafostar.Clapper)$, float on"
        "match:title ^(Authentication Required)$, float on"
        "match:class (codium|codium-url-handler|VSCodium), match:title negative:(.*codium.*|.*VSCodium.*), float on"
        "match:class ^(com.heroicgameslauncher.hgl)$, match:title negative:(Heroic Games Launcher), float on"
        "match:class ^([Ss]team)$, match:title negative:^([Ss]team)$, float on"
        "match:class ([Tt]hunar), match:title negative:(.*[Tt]hunar.*), float on"
        "match:initial_title (Add Folder to Workspace), float on"
        "match:initial_title (Open Files), float on"
        "match:initial_title (wants to save), float on"
        "match:initial_title (Open Files), size 70% 60%"
        "match:initial_title (Add Folder to Workspace), size 70% 60%"
        "match:tag settings, size 70% 70%"
        "match:class ^([Ff]erdium)$, size 60% 70%"
        "match:tag browser, opacity 1.0 1.0"
        "match:tag projects, opacity 0.9 0.8"
        "match:tag im, opacity 0.94 0.86"
        "match:tag file-manager, opacity 0.9 0.8"
        "match:tag terminal, opacity 0.8 0.7"
        "match:tag settings, opacity 0.8 0.7"
        "match:class ^(gedit|org.gnome.TextEditor|mousepad)$, opacity 0.8 0.7"
        "match:class ^(seahorse)$, opacity 0.9 0.8 # gnome-keyring gui"
        "match:title ^(Picture-in-Picture)$, opacity 0.95 0.75"
        "match:title ^(Picture-in-Picture)$, pin on"
        "match:title ^(Picture-in-Picture)$, keep_aspect_ratio on"
        "match:tag games, no_blur on"
        "match:tag games, fullscreen on"
      ];
    };

    extraConfig = "
      monitor=,preferred,auto,auto
      ${extraMonitorSettings}
    ";
  };
}
