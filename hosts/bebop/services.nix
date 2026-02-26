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
in {
  environment.systemPackages = with pkgs; [
    systemdgenie
    systemctl-tui
  ];
  services = {
    chrony.enable = true;
    tailscale = {
      enable = true;
      extraUpFlags = ["--accept-routes"];
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
        };
      };
    };
    dbus.enable = true;
    displayManager = {
      sddm = {
        enable = true;
        wayland.enable = true;
      };
      defaultSession = "hyprland";
    };
    #desktopManager.plasma6.enable = true;
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
          command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd Hyprland"; # start Hyprland with a TUI login manager
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
