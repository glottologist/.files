# Nix guideline compliant 2026-09-01
{ username }:
let
  inherit (import ../../../homes/${username}/variables.nix)
    browser
    terminal
    ;

  binding = group: description: value: {
    inherit group description;
    binding = value;
  };

  directions = [
    {
      arrow = "left";
      letter = "h";
      code = "43";
      dispatch = "l";
      name = "left";
    }
    {
      arrow = "right";
      letter = "l";
      code = "46";
      dispatch = "r";
      name = "right";
    }
    {
      arrow = "up";
      letter = "k";
      code = "45";
      dispatch = "u";
      name = "up";
    }
    {
      arrow = "down";
      letter = "j";
      code = "44";
      dispatch = "d";
      name = "down";
    }
  ];

  workspaceNumbers = builtins.genList (index: index + 1) 22;
  workspaceKey =
    workspace:
    if workspace < 10 then
      builtins.toString workspace
    else if workspace == 10 then
      "0"
    else
      "F${builtins.toString (workspace - 10)}";

  moveWindowBindings =
    builtins.map (
      direction:
      binding "Windows" "Move window ${direction.name}"
        "$modifier SHIFT,${direction.arrow},movewindow,${direction.dispatch}"
    ) directions
    ++ builtins.map (
      direction:
      binding "Windows" "Move window ${direction.name}"
        "$modifier SHIFT,${direction.letter},movewindow,${direction.dispatch}"
    ) directions;

  swapWindowBindings =
    builtins.map (
      direction:
      binding "Windows" "Swap window ${direction.name}"
        "$modifier ALT, ${direction.arrow}, swapwindow,${direction.dispatch}"
    ) directions
    ++ builtins.map (
      direction:
      binding "Windows" "Swap window ${direction.name}"
        "$modifier ALT, ${direction.code}, swapwindow,${direction.dispatch}"
    ) directions;

  focusBindings =
    builtins.map (
      direction:
      binding "Windows" "Focus ${direction.name}"
        "$modifier,${direction.arrow},movefocus,${direction.dispatch}"
    ) directions
    ++ builtins.map (
      direction:
      binding "Windows" "Focus ${direction.name}"
        "$modifier,${direction.letter},movefocus,${direction.dispatch}"
    ) directions;

  switchWorkspaceBindings = builtins.map (
    workspace:
    binding "Workspaces" "Switch to workspace ${builtins.toString workspace}"
      "$modifier,${workspaceKey workspace},workspace,${builtins.toString workspace}"
  ) workspaceNumbers;

  moveToWorkspaceBindings = builtins.map (
    workspace:
    binding "Workspaces" "Move window to workspace ${builtins.toString workspace}"
      "$modifier SHIFT,${workspaceKey workspace},movetoworkspace,${builtins.toString workspace}"
  ) workspaceNumbers;
in
{
  bind = [
    (binding "Applications" "Terminal" "$modifier,Return,exec,${terminal}")
    (binding "Applications" "Action menu" "$modifier,SPACE,exec,omarchy-menu")
    (binding "Utilities" "Keybindings" "$modifier,K,exec,list-keybinds")
    (binding "Applications" "App launcher" "$modifier,D,exec,rofi-launcher")
    (binding "Applications" "Web search" "$modifier SHIFT,W,exec,web-search")
    (binding "Session" "Logout menu" "$modifier SHIFT,Q,exec,wlogout --css ~/.config/wlogout/main.css")
    (binding "Session" "Lock" "$modifier SHIFT,L,exec,hyprlock")
    (binding "Applications" "Change wallpaper" "$modifier ALT,W,exec,wallsetter")
    (binding "Session" "Clear notifications" "$modifier SHIFT,N,exec,swaync-client -rs")
    (binding "Applications" "Browser" "$modifier,W,exec,${browser}")
    (binding "Utilities" "Emoji picker" "$modifier,E,exec,emopicker9000")
    (binding "Capture" "Screenshot" "$modifier,S,exec,screenshootin")
    (binding "Capture" "Screen recorder" "$modifier SHIFT,V,exec,gpu-screen-recorder-gtk")
    (binding "Applications" "Brave" "$modifier,B,exec,brave")
    (binding "Applications" "Obsidian" "$modifier,O,exec,obsidian")
    (binding "Clipboard" "Copy" "$modifier,C,exec,unified-clipboard copy")
    (binding "Clipboard" "Cut" "$modifier,X,exec,unified-clipboard cut")
    (binding "Clipboard" "Paste" "$modifier,V,exec,unified-clipboard paste")
    (binding "Clipboard" "Clipboard history"
      "$modifier CTRL,V,exec,cliphist list | rofi -dmenu | cliphist decode | wl-copy"
    )
    (binding "Capture" "Colour picker" "$modifier ALT,C,exec,hyprpicker -a")
    (binding "Capture" "OCR region to clipboard" "$modifier CTRL,Print,exec,ocr-clip")
    (binding "Reminders" "Set reminder" "$modifier CTRL,R,exec,desktop-reminder set")
    (binding "Reminders" "Show reminders" "$modifier CTRL ALT,R,exec,desktop-reminder list")
    (binding "Reminders" "Clear reminders" "$modifier CTRL SHIFT,R,exec,desktop-reminder clear")
    (binding "Agents" "Herdr" "$modifier CTRL,Return,exec,${terminal} -e herdr")
    (binding "Agents" "Default agent" "$modifier SHIFT CTRL,A,exec,${terminal} -e default-agent")
    (binding "Applications" "ChatGPT" "$modifier SHIFT,A,exec,gtk-launch chatgpt-web")
    (binding "Applications" "Grok" "$modifier SHIFT ALT,A,exec,gtk-launch grok-web")
    (binding "Applications" "HEY Email" "$modifier SHIFT,E,exec,gtk-launch hey-email")
    (binding "Applications" "New HEY email" "$modifier SHIFT ALT,E,exec,gtk-launch hey-email")
    (binding "Applications" "HEY Calendar" "$modifier SHIFT ALT,C,exec,gtk-launch hey-calendar")
    (binding "Applications" "YouTube" "$modifier SHIFT,Y,exec,gtk-launch youtube-web")
    (binding "Applications" "X" "$modifier SHIFT,X,exec,gtk-launch x-web")
    (binding "Applications" "Google Photos" "$modifier SHIFT,P,exec,gtk-launch google-photos-web")
    (binding "Applications" "WhatsApp" "$modifier SHIFT ALT,G,exec,gtk-launch whatsapp-web")
    (binding "Applications" "Ghostty" "$modifier,G,exec,ghostty")
    (binding "Applications" "GIMP" "$modifier,I,exec,gimp")
    (binding "Applications" "Dropdown terminal" "$modifier,T,exec,pypr toggle term")
    (binding "Media" "Audio controls" "$modifier,M,exec,pavucontrol")
    (binding "Windows" "Close window" "$modifier,Q,killactive,")
    (binding "Windows" "Toggle pseudo window" "$modifier,P,pseudo,")
    (binding "Windows" "Toggle split" "$modifier SHIFT,I,layoutmsg,togglesplit")
    (binding "Windows" "Fullscreen" "$modifier,F,fullscreen,")
    (binding "Windows" "Toggle floating" "$modifier SHIFT,F,togglefloating,")
    (binding "Windows" "Toggle all floating" "$modifier ALT,F,workspaceopt, allfloat")
    (binding "Session" "Exit Hyprland" "$modifier SHIFT,C,exit,")
  ]
  ++ moveWindowBindings
  ++ swapWindowBindings
  ++ focusBindings
  ++ switchWorkspaceBindings
  ++ [
    (binding "Workspaces" "Move window to special workspace"
      "$modifier ALT SHIFT,SPACE,movetoworkspace,special"
    )
    (binding "Workspaces" "Toggle special workspace" "$modifier ALT,SPACE,togglespecialworkspace")
  ]
  ++ moveToWorkspaceBindings
  ++ [
    (binding "Workspaces" "Next workspace" "$modifier CONTROL,right,workspace,e+1")
    (binding "Workspaces" "Previous workspace" "$modifier CONTROL,left,workspace,e-1")
    (binding "Workspaces" "Next workspace" "$modifier,mouse_down,workspace, e+1")
    (binding "Workspaces" "Previous workspace" "$modifier,mouse_up,workspace, e-1")
    (binding "Windows" "Focus next window" "ALT,Tab,cyclenext")
    (binding "Windows" "Bring active window to top" "ALT,Tab,bringactivetotop")
    (binding "Media" "Volume up" ",XF86AudioRaiseVolume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+")
    (binding "Media" "Volume down"
      ",XF86AudioLowerVolume,exec,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
    )
    (binding "Media" "Mute audio" " ,XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")
    (binding "Media" "Play or pause" ",XF86AudioPlay, exec, playerctl play-pause")
    (binding "Media" "Play or pause" ",XF86AudioPause, exec, playerctl play-pause")
    (binding "Media" "Next track" ",XF86AudioNext, exec, playerctl next")
    (binding "Media" "Previous track" ",XF86AudioPrev, exec, playerctl previous")
    (binding "Media" "Brightness down" ",XF86MonBrightnessDown,exec,brightnessctl set 5%-")
    (binding "Media" "Brightness up" ",XF86MonBrightnessUp,exec,brightnessctl set +5%")
  ];

  bindm = [
    (binding "Windows" "Move window" "$modifier, mouse:272, movewindow")
    (binding "Windows" "Resize window" "$modifier, mouse:273, resizewindow")
  ];
}
