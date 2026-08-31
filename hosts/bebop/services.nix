{
  config,
  lib,
  pkgs,
  modulesPath,
  inputs,
  ...
}: let
  inherit (import ./variables.nix) username;
  syncthingSecrets = import ../../secrets/syncthing.nix;
  hosts = import ../../secrets/hosts.nix;

  # Both Hyprland configurations live in ~/.config/hypr; Hyprland prefers
  # hyprland.lua when run bare, so each session names its file explicitly.
  hyprlandWith = configFile:
    pkgs.writeShellScript "hyprland-${configFile}" ''
      exec ${config.programs.hyprland.package}/bin/Hyprland --config "$HOME/.config/hypr/${configFile}"
    '';
  # The omarchy session needs OMARCHY_PATH before Hyprland parses its Lua
  # config, and the quickshell process and every omarchy-* script inherit
  # the session PATH.
  omarchySession = pkgs.writeShellScript "hyprland-omarchy-session" ''
    export OMARCHY_PATH="${pkgs.omarchy-nixified}"
    export PATH="${pkgs.omarchy-nixified}/bin:${pkgs.omarchy-nixified.runtimePath}:$PATH"
    exec ${config.programs.hyprland.package}/bin/Hyprland --config "$HOME/.config/hypr/omarchy.lua"
  '';
  hyprlandSessions =
    pkgs.runCommand "hyprland-sessions" {
      passthru.providedSessions = ["hyprland-classic" "hyprland-caelestia" "hyprland-omarchy"];
    } ''
      mkdir -p $out/share/wayland-sessions
      cat > $out/share/wayland-sessions/hyprland-classic.desktop <<EOF
      [Desktop Entry]
      Type=Application
      Name=Hyprland (Classic)
      Comment=Hyprland with the waybar, rofi and dunst stack
      Exec=${hyprlandWith "hyprland.conf"}
      DesktopNames=Hyprland
      EOF
      cat > $out/share/wayland-sessions/hyprland-caelestia.desktop <<EOF
      [Desktop Entry]
      Type=Application
      Name=Hyprland (Caelestia)
      Comment=Hyprland with the caelestia shell
      Exec=${hyprlandWith "hyprland.lua"}
      DesktopNames=Hyprland
      EOF
      cat > $out/share/wayland-sessions/hyprland-omarchy.desktop <<EOF
      [Desktop Entry]
      Type=Application
      Name=Hyprland (Omarchy)
      Comment=Hyprland with the Omarchy 4 quickshell desktop
      Exec=${omarchySession}
      DesktopNames=Hyprland
      EOF
    '';
  # programs.hyprland adds hyprland.desktop and hyprland-uwsm.desktop to the
  # session list; bare Hyprland now resolves to the Lua config, so hide them.
  greeterSessions =
    pkgs.runCommand "greeter-sessions" {} ''
      mkdir -p $out
      for f in ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions/*.desktop; do
        case "$(basename "$f")" in
          hyprland.desktop | hyprland-uwsm.desktop) continue ;;
        esac
        ln -s "$f" "$out/"
      done
    '';
in {
  environment.systemPackages = with pkgs; [
    systemdgenie
    systemctl-tui
  ];
  services = {
    chrony = {
      enable = true;
      extraConfig = "makestep 1 -1";
    };
    syncthing = {
      enable = true;
      openDefaultPorts = true;
      user = "${username}";
      dataDir = "/home/${username}/syncthing";
      configDir = "/home/${username}/syncthing/.config/syncthing";
      settings = {
        gui = {
          user = "${username}";
          password = "syncthing";
        };
        devices = {
          "CALYPSO" = {
            id = syncthingSecrets.CALYPSO_ID;
            addresses = ["tcp://${hosts.calypso}:22000" "dynamic"];
          };
          "MARAUDER" = {
            id = syncthingSecrets.MARAUDER_ID;
            addresses = ["tcp://${hosts.marauder}:22000" "dynamic"];
          };
          "RAPTOR" = {id = syncthingSecrets.RAPTOR_ID;};
          "CIRCE" = {
            id = syncthingSecrets.CIRCE_ID;
            addresses = ["tcp://${hosts.circe}:22000" "dynamic"];
          };
        };
        folders = {
          "BEBOP" = {
            path = "/home/${username}/syncthing/BEBOP";
            devices = ["CALYPSO"];
          };
          "MARAUDER" = {
            path = "/home/${username}/syncthing/MARAUDER";
            devices = ["MARAUDER"];
          };
          "RAPTOR" = {
            path = "/home/${username}/syncthing/RAPTOR";
            devices = ["RAPTOR"];
          };
          "CIRCE" = {
            path = "/home/${username}/syncthing/CIRCE";
            devices = ["CIRCE"];
          };
          "circe" = {
            id = "2rhrs-g2dmh";
            path = "/home/${username}/circe";
            devices = ["CIRCE"];
          };
          "BEBOP_BACKUP" = {
            id = "7rcyx-qs5iz";
            path = "/home/${username}/BEBOP_BACKUP";
            devices = ["CALYPSO"];
          };
          "TRANSFER" = {
            id = "aekzk-4jpel";
            path = "/home/${username}/TRANSFER";
            devices = ["MARAUDER" "CALYPSO"];
          };
        };
      };
    };
    dbus.enable = true;
    displayManager = {
      sddm = {
        enable = true;
        wayland.enable = true;
      };
      defaultSession = "hyprland-classic";
      sessionPackages = [hyprlandSessions];
    };
    desktopManager.plasma6.enable = true;
    pulseaudio.enable = false;
    printing.enable = true;
    libinput.enable = true;
    fstrim.enable = true;
    gvfs.enable = true;
    openssh.enable = true;
    flatpak.enable = true;
    blueman.enable = true;
    gnome.gnome-keyring.enable = true;
    mullvad-vpn = {
      enable = true;
      package = pkgs.mullvad-vpn;
    };
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    smartd = {
      enable = false;
      autodetect = true;
    };

    xserver = {
      enable = true;
      xkb = {
        layout = "gb";
        variant = "";
      };
      videoDrivers = ["amdgpu"];
      displayManager.sessionCommands = ''
        eval $(gnome-keyring-daemon --start --daemonize --components=ssh,secrets)
        export SSH_AUTH_SOCK
      '';
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    greetd = {
      enable = true;
      settings = {
        default_session = {
          user = "${username}";
          # F2 opens the session menu: both Hyprland profiles and Plasma.
          # --sessions replaces tuigreet's XDG_DATA_DIRS fallback (the source
          # of the identically-named "Hyprland" entries), so only the named
          # sessions appear. --cmd makes the classic profile the default
          # until a session is remembered.
          command = "${pkgs.tuigreet}/bin/tuigreet --time --remember-session --sessions ${greeterSessions} --cmd ${hyprlandWith "hyprland.conf"}";
        };
      };
    };
  };
  systemd.services = {
    flatpak-repo = {
      wantedBy = ["multi-user.target"];
      path = [pkgs.flatpak];
      script = ''
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
      '';
    };
    syncthing.environment.STNODEFAULTFOLDER = "true";
  };
}
