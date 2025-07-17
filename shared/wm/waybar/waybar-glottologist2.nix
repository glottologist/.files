{
  pkgs,
  config,
  lib,
  ...
}: let
  terminal = "ghostty";
  base00 = "eff1f5"; # Base - main background (light)
  base01 = "e6e9ef"; # Mantle - lighter background
  base02 = "dce0e8"; # Crust - selection background
  base03 = "bcc0cc"; # Surface1 - comments, invisibles
  base04 = "acb0be"; # Surface2 - dark foreground
  base05 = "4c4f69"; # Text - default foreground (dark)
  base06 = "5c5f77"; # Subtext1 - light foreground
  base07 = "6c6f85"; # Subtext0 - lightest foreground
  base08 = "d20f39"; # Red - variables, markup
  base09 = "fe640b"; # Peach - integers, constants
  base0A = "df8e1d"; # Yellow - classes, search
  base0B = "40a02b"; # Green - strings, additions
  base0C = "179299"; # Teal - support, regex
  base0D = "1e66f5"; # Blue - functions, methods
  base0E = "8839ef"; # Mauve - keywords, storage
  base0F = "dc8a78"; # Rosewater - deprecated, tags
in
  with lib; {
    # Configure & Theme Waybar
    programs.waybar = {
      enable = true;
      package = pkgs.waybar;
      settings = [
        {
          layer = "top";
          position = "bottom";

          modules-left = ["custom/startmenu" "custom/notification" "tray" "hyprland/window"];
          modules-center = ["hyprland/workspaces"];
          modules-right = ["custom/systemstats" "network" "pulseaudio" "battery" "clock" "custom/exit"];

          "hyprland/workspaces" = {
            format = "{name}";
            format-icons = {
              default = " ";
              active = " ";
              urgent = " ";
            };
            "tooltip": true,
            "tooltip-format": "Workspace {name}",
            on-scroll-up = "hyprctl dispatch workspace e+1";
            on-scroll-down = "hyprctl dispatch workspace e-1";
          };
          "clock" = {
            format = '' {:%H:%M}'';
            /*
            ''{: %I:%M %p}'';
            */
            tooltip = true;
            tooltip-format = "<big>{:%A, %d %B %Y }</big><tt><small>{calendar}</small></tt>";
          };
          "hyprland/window" = {
            max-length = 60;
            separate-outputs = false;
          };
          "memory" = {
            interval = 5;
            format = " {}%";
            tooltip = true;
            on-click = "${terminal} -e btop";
          };
          "cpu" = {
            interval = 5;
            format = " {usage:2}%";
            tooltip = true;
            on-click = "${terminal} -e btop";
          };
          "disk" = {
            format = " {free}";
            tooltip = true;
            on-click = "${terminal} -e ncdu";
          };
          "network" = {
            format-icons = ["󰤯" "󰤟" "󰤢" "󰤥" "󰤨"];
            format-ethernet = " {bandwidthDownBits}";
            format-wifi = " {bandwidthDownBits}";
            format-disconnected = "󰤮";
            tooltip = false;
            on-click = "${terminal} -e speedtest";
          };
		  
		   "custom/systemstats" = {
            format = "{}";
            interval = 5;
            exec = "echo \"󰍛 $(free | awk '/Mem:/ {printf \"%.0f%%\", ($3/$2)*100}') | 󰻠 $(cat /proc/loadavg | awk '{printf \"%.1f\", $1}') | 󰋊 $(df -h / | awk 'NR==2 {print $5}')\"";
            tooltip = true;
            on-click = "${terminal} -e btop & ${terminal} -e ncdu";
          };
          "tray" = {
            spacing = 12;
          };
          "pulseaudio" = {
            format = "{icon} {volume}% {format_source}";
            format-bluetooth = "{volume}% {icon} {format_source}";
            format-bluetooth-muted = " {icon} {format_source}";
            format-muted = " {format_source}";
            format-source = " {volume}%";
            format-source-muted = "";
            format-icons = {
              headphone = "";
              hands-free = "";
              headset = "";
              phone = "";
              portable = "";
              car = "";
              default = ["" "" ""];
            };
            on-click = "pavucontrol";
          };
          "custom/exit" = {
            tooltip = false;
            format = "⏻";
            on-click = "sleep 0.1 && wlogout";
          };
          "custom/startmenu" = {
            tooltip = false;
            format = " ";
            # exec = "rofi -show drun";
            on-click = "rofi -show drun";
          };
          "idle_inhibitor" = {
            format = "{icon}";
            format-icons = {
              activated = " ";
              deactivated = " ";
            };
            tooltip = "true";
          };
          "custom/notification" = {
            tooltip = false;
            format = "{icon} {}";
            format-icons = {
              notification = "<span foreground='red'><sup></sup></span>";
              none = "";
              dnd-notification = "<span foreground='red'><sup></sup></span>";
              dnd-none = "";
              inhibited-notification = "<span foreground='red'><sup></sup></span>";
              inhibited-none = "";
              dnd-inhibited-notification = "<span foreground='red'><sup></sup></span>";
              dnd-inhibited-none = "";
            };
            return-type = "json";
            exec-if = "which swaync-client";
            exec = "swaync-client -swb";
            on-click = "swaync-client -t";
            escape = true;
          };
          "battery" = {
            states = {
              warning = 30;
              critical = 15;
            };
            format = "{icon} {capacity}%";
            format-charging = "󰂄 {capacity}%";
            format-plugged = "󱘖 {capacity}%";
            format-icons = ["󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
            on-click = "";
            tooltip = false;
          };
        }
      ];
      style = concatStrings [
        ''
          * {
            font-size: 14px;
            font-family: JetBrainsMono Nerd Font, Font Awesome, sans-serif;
            font-weight: bold;
          }
          window#waybar {
            /*

              background-color: rgba(26,27,38,0);
              border-bottom: 1px solid rgba(26,27,38,0);
              border-radius: 0px;
              color: #${base0F};
            */

            background-color: rgba(26,27,38,0);
            border-bottom: 1px solid rgba(26,27,38,0);
            border-radius: 0px;
            color: #${base0F};
          }
          #workspaces {
            /*
              Eternal
              background: linear-gradient(180deg, #${base00}, #${base01});
              margin: 5px 5px 5px 0px;
              padding: 0px 10px;
              border-radius: 0px 15px 15px 0px;
              border: 0px;
              font-style: normal;
              color: #${base00};
            */
            background: linear-gradient(45deg, #${base01}, #${base01});
            margin: 2px;
            padding: 0px 1px;
            border-radius: 15px;
            border: 0px;
            font-style: normal;
            color: #${base00};
          }
          #workspaces button {
            padding: 0px 5px;
            margin: 4px 3px;
            border-radius: 15px;
            border: 0px;
            color: #${base00};
            background: linear-gradient(45deg, #${base0D}, #${base0E});
            opacity: 0.5;
            transition: all 0.3s ease-in-out;
          }
          #workspaces button.active {
            padding: 0px 5px;
            margin: 4px 3px;
            border-radius: 15px;
            border: 0px;
            color: #${base00};
            background: linear-gradient(45deg, #${base0D}, #${base0E});
            opacity: 1.0;
            min-width: 40px;
            transition: all 0.3s ease-in-out;
          }
          #workspaces button:hover {
            border-radius: 15px;
            color: #${base00};
            background: linear-gradient(45deg, #${base0D}, #${base0E});
            opacity: 0.8;
          }
          tooltip {
            background: #${base00};
            border: 1px solid #${base0E};
            border-radius: 10px;
          }
          tooltip label {
            color: #${base07};
          }
          #window {
            margin: 2px;
            padding: 2px 20px;
            color: #${base05};
            background: #${base01};
            border-radius: 15px 15px 15px 15px;
          }
          #memory {
            color: #${base0F};
            background: #${base01};
            margin: 2px;
            padding: 2px 20px;
            border-radius: 15px 15px 15px 15px;
          }
          #clock {
            color: #${base0B};
              background: #${base00};
              border-radius: 15px 15px 15px 15px;
              margin: 2px;
              padding: 2px 20px;
          }
          #idle_inhibitor {
            color: #${base0A};
              background: #${base00};
              border-radius: 15px 15px 15px 15px;
              margin: 2px;
              padding: 2px 20px;
          }
          #cpu {
            color: #${base07};
              background: #${base00};
              border-radius: 15px 15px 15px 15px;
              margin: 2px;
              padding: 2px 20px;
          }
		  #custom-systemstats {
            color: #${base0C};
              background: #${base00};
              border-radius: 15px 15px 15px 15px;
              margin: 2px;
              padding: 2px 20px;
          }
          #disk {
            color: #${base0F};
              background: #${base00};
              border-radius: 15px 15px 15px 15px;
              margin: 2px;
              padding: 2px 20px;
          }
          #battery {
            color: #${base08};
            background: #${base00};
            border-radius: 15px 15px 15px 15px;
            margin: 2px;
            padding: 2px 20px;
          }
          #network {
            color: #${base09};
            background: #${base00};
            border-radius: 15px 15px 15px 15px;
            margin: 2px;
            padding: 2px 20px;
          }
          #tray {
            color: #${base05};
            background: #${base00};
            border-radius: 15px 15px 15px 15px;
            margin: 2px;
            padding: 2px 15px;
          }
          #pulseaudio {
            color: #${base0D};
            background: #${base01};
            margin: 2px;
            padding: 2px 20px;
            border-radius: 15px 15px 15px 15px;
          }
          #custom-notification {
            color: #${base0C};
            background: #${base00};
            border-radius: 15px 15px 15px 15px;
            margin: 2px;
            padding: 2px 20px;
          }
          #custom-startmenu {
            color: #${base0E};
            background: #${base00};
            border-radius: 0px 15px 15px 0px;
            margin: 2px 2px 2px 0px;
            padding: 2px 20px;
          }
          #idle_inhibitor {
            color: #${base09};
            background: #${base00};
            border-radius: 15px 15px 15px 15px;
            margin: 2px;
            padding: 2px 20px;
          }
          #custom-exit {
            color: #${base0E};
            background: #${base00};
            border-radius: 15px 0px 0px 15px;
            margin: 2px 0px 2px 2px;
            padding: 2px 20px;
          }
        ''
      ];
    };
  }
