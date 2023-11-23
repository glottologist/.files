{
  config,
  lib,
  pkgs,
  stdenv,
  ...
}: {
  home.packages = with pkgs; [
    killall
    light
    xorg.xbacklight
    brightnessctl
  ];
  imports = [
  ];
  home.sessionVariables = {
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";
  };

  systemd.user.targets.hyprland-session.Unit.Wants = ["xdg-desktop-autostart.target"];

  wayland.windowManager.hyprland = {
    enable = true;
    systemdIntegration = true;
    xwayland.enable = true;
    extraConfig = ''
      monitor=eDP-1,preferred,auto,1.5
      monitor=,1920x1080@60,auto,1

      env = XCURSOR_SIZE,24

      input {
        kb_layout = gb
        kb_variant =
        kb_model =
        kb_options =
        kb_rules =

        follow_mouse = 1

        touchpad {
            natural_scroll = yes
            tap-and-drag = true
        }

        sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
      }

      general {
        gaps_in = 5
        gaps_out = 20
        border_size = 2
        col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
        col.inactive_border = rgba(595959aa)
        layout = dwindle
      }

      decoration {
          rounding = 10
          blur {
            enabled = true
            size = 8
            new_optimizations = true
            passes = 2
          }

          drop_shadow = yes
          shadow_range = 15
          shadow_offset = 0, 0
          shadow_render_power = 3
          col.shadow = rgba(1a1a1aee)
      }

      animations {
        enabled = yes
        bezier = myBezier, 0.05, 0.9, 0.1, 1.05
        animation = windows, 1, 7, myBezier
        animation = windowsOut, 1, 7, default, popin 80%
        animation = border, 1, 10, default
        animation = borderangle, 1, 8, default
        animation = fade, 1, 7, default
        animation = workspaces, 1, 6, default
      }

      dwindle {
        pseudotile = yes # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
        preserve_split = yes # you probably want this
        smart_split = true;
      }

      master {
        new_is_master = true
      }

      gestures {
        workspace_swipe = on
      }

      binds {
        workspace_back_and_forth = true
      }

      device:epic-mouse-v1 {
        sensitivity = -0.5
      }
      misc {
          disable_hyprland_logo = true
          disable_splash_rendering = true
      }

      windowrule=float,Rofi

      $mainMod = SUPER

      # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
      bind = $mainMod, Return, exec, foot
      bind = $mainMod, B, exec, qutebrowser
      bind = $mainMod SHIFT , B, exec, brave
      bind = $mainMod, T, exec, thunderbird
      bind = $mainMod SHIFT, T, exec, telegram
      bind = $mainMod, S, exec, slack
      bind = $mainMod SHIFT, S, exec, flameshot gui
      bind = $mainMod, K, exec, kitty
      bind = $mainMod, O, exec, obsidian
      bind = $mainMod, F, exec,firefox
      bind = $mainMod, D, exec,discord
      bind = $mainMod, M, exec,spotify
      bind = $mainMod, V, exec,veracrypt
      bind = $mainMod, R, exec, pkill rofi || rofi -show drun -show-icons
      bind = $mainMod, C, killactive,
      bind = $mainMod SHIFT, Q, exit,
      bind = $mainMod SHIFT, F, exec, dolphin
      bind = $mainMod SHIFT, V, togglefloating,
      bind = $mainMod SHIFT, P, pseudo, # dwindle
      bind = $mainMod SHIFT, D, togglesplit, # dwindle
      bind = $mainMod SHIFT, F, fullscreen
      bind = $mainMod SHIFT, L, exec, swaylock

      bind = , XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+
      bind = , XF86AudioLowerVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%-
      bind = , XF86AudioMute, exec, wpctl set-mute -l 1.5 @DEFAULT_AUDIO_SINK@ toggle
      bind = , XF86AudioMicMute, exec, wpctl set-mute -l 1.5 @DEFAULT_AUDIO_SOURCE@ toggle

      bind = , XF86MonBrightnessUp, exec, brightnessctl s 10%+
      bind = , XF86MonBrightnessDown, exec, brightnessctl s 10%-

      # Move focus with mainMod + arrow keys
      bind = $mainMod, H, movefocus, l
      bind = $mainMod, L, movefocus, r
      bind = $mainMod, K, movefocus, u
      bind = $mainMod, J, movefocus, d

      # Switch workspaces with mainMod + [0-9]
      bind = $mainMod, 1, workspace, 1
      bind = $mainMod, 2, workspace, 2
      bind = $mainMod, 3, workspace, 3
      bind = $mainMod, 4, workspace, 4
      bind = $mainMod, 5, workspace, 5
      bind = $mainMod, 6, workspace, 6
      bind = $mainMod, 7, workspace, 7
      bind = $mainMod, 8, workspace, 8
      bind = $mainMod, 9, workspace, 9
      bind = $mainMod, 0, workspace, 10

      # Move active window to a workspace with mainMod + SHIFT + [0-9]
      bind = $mainMod SHIFT, 1, movetoworkspace, 1
      bind = $mainMod SHIFT, 2, movetoworkspace, 2
      bind = $mainMod SHIFT, 3, movetoworkspace, 3
      bind = $mainMod SHIFT, 4, movetoworkspace, 4
      bind = $mainMod SHIFT, 5, movetoworkspace, 5
      bind = $mainMod SHIFT, 6, movetoworkspace, 6
      bind = $mainMod SHIFT, 7, movetoworkspace, 7
      bind = $mainMod SHIFT, 8, movetoworkspace, 8
      bind = $mainMod SHIFT, 9, movetoworkspace, 9
      bind = $mainMod SHIFT, 0, movetoworkspace, 10

      # Scroll through existing workspaces with mainMod + scroll
      bind = $mainMod, mouse_down, workspace, e+1
      bind = $mainMod, mouse_up, workspace, e-1

      # Move/resize windows with mainMod + LMB/RMB and dragging
      bindm = $mainMod, mouse:272, movewindow
      bindm = $mainMod, mouse:273, resizewindow


      ## Autostarts
      exec-once = hyprctl setcursor Bibata-Modern-Ice 22
      exec-once = systemctl --user import-environment &
      exec-once = hash dbus-update-activation-environment 2>/dev/null &
      exec-once = dbus-update-activation-environment --systemd &
      exec-once = dunst
      exec-once = nm-applet --indicator
      exec-once = blueman-applet
      exec-once = swww init && sleep 1 && wallpaper
      exec-once = waybar &

    '';
  };
}
