# The greeter offers two sessions and Plasma is the default.
#
# That choice is about the hardware rather than about taste. The Pocket 3's
# panel is a 1200x1920 OLED at roughly 283 DPI, mounted rotated, with a
# touchscreen and an accelerometer; Plasma's Wayland session handles rotation,
# fractional scaling and touch input without being told, which is exactly what
# one wants on first boot and when the machine is used as a tablet. The
# Hyprland classic profile sits alongside it for keyboard-driven work, and its
# rotation comes from the monitor line in homes/jrt/variables.nix.
#
# Caelestia and Omnixy are deliberately absent: both are tuned to Bebop's
# monitor geometry and would need their own rotation work for no gain here.
{
  config,
  pkgs,
  ...
}:
let
  inherit (import ./variables.nix) username;

  hyprlandClassic = pkgs.writeShellScript "hyprland-classic" ''
    exec ${config.programs.hyprland.package}/bin/Hyprland --config "$HOME/.config/hypr/hyprland.conf"
  '';

  hyprlandSessions = pkgs.runCommand "hyprland-sessions" {
    passthru.providedSessions = [ "hyprland-classic" ];
  } ''
    mkdir -p $out/share/wayland-sessions
    cat > $out/share/wayland-sessions/hyprland-classic.desktop <<EOF
    [Desktop Entry]
    Type=Application
    Name=Hyprland (Classic)
    Comment=Hyprland with the waybar, rofi and dunst stack
    Exec=${hyprlandClassic}
    DesktopNames=Hyprland
    EOF
  '';

  # programs.hyprland contributes hyprland.desktop and hyprland-uwsm.desktop of
  # its own, which would show up beside our named entry as two more lines
  # reading simply "Hyprland". Curating the directory is what keeps the menu
  # honest about what each entry actually starts.
  greeterSessions = pkgs.runCommand "greeter-sessions" { } ''
    mkdir -p $out
    for f in ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions/*.desktop; do
      case "$(basename "$f")" in
        hyprland.desktop | hyprland-uwsm.desktop) continue ;;
      esac
      ln -s "$f" "$out/"
    done
  '';
in
{
  services = {
    greetd = {
      enable = true;
      settings.default_session = {
        user = "${username}";
        # F2 opens the session menu. --cmd names Plasma as the default until a
        # session has been remembered.
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember-session --sessions ${greeterSessions} --cmd startplasma-wayland";
      };
    };

    displayManager.sessionPackages = [ hyprlandSessions ];
    desktopManager.plasma6.enable = true;

    xserver = {
      enable = true;
      xkb = {
        layout = "gb";
        variant = "";
      };
      # nixos-hardware's gpd/pocket-3 module sets services.xserver.dpi = 280.
    };

    dbus.enable = true;
    libinput.enable = true;
    gvfs.enable = true;
    fstrim.enable = true;
    printing.enable = true;
    blueman.enable = true;
    gnome.gnome-keyring.enable = true;

    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "prohibit-password";
        PubkeyAuthentication = true;
      };
    };

    chrony = {
      enable = true;
      extraConfig = "makestep 1 -1";
    };

    # Unlike the Hetzner hosts, this machine should suspend when the lid closes:
    # it runs on a battery and nobody is reaching it over RDP.
    logind.settings.Login = {
      HandleLidSwitch = "suspend";
      HandleLidSwitchExternalPower = "suspend";
    };
  };

  security.rtkit.enable = true;

  security.polkit = {
    enable = true;
    extraConfig = ''
      polkit.addRule(function(action, subject) {
        if ( subject.isInGroup("users") && (
         action.id == "org.freedesktop.login1.reboot" ||
         action.id == "org.freedesktop.login1.reboot-multiple-sessions" ||
         action.id == "org.freedesktop.login1.power-off" ||
         action.id == "org.freedesktop.login1.power-off-multiple-sessions"
        ))
        { return polkit.Result.YES; }
      })
    '';
  };
}
