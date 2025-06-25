{
  config,
  lib,
  pkgs,
  modulesPath,
  useHyprland,
  ...
}: let
  inherit (import ./variables.nix) username;
in {
  services = {
    displayManager.sddm.enable = !useHyprland;
    desktopManager.plasma6.enable = !useHyprland;
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
      enable = !useHyprland;
      xkb = {
        layout = "gb";
        variant = "";
      };
      videoDrivers = ["amdgpu"];
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    greetd = {
      enable = !useHyprland;
      vt = 3;
      settings = {
        default_session = {
          user = "${username}";
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland"; # start Hyprland with a TUI login manager
        };
      };
    };
  };
  systemd.services.flatpak-repo = {
    wantedBy = ["multi-user.target"];
    path = [pkgs.flatpak];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };
}
