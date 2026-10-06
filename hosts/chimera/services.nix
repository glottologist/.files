# The greeter offers three sessions and Omnixy is the default.
#
# The Pocket 3's panel is a 1200x1920 OLED at roughly 283 DPI, mounted
# rotated, with a touchscreen and an accelerometer. Both Hyprland profiles,
# Omnixy and classic, take their rotation from the monitor line in
# homes/jrt/variables.nix. Plasma's Wayland session stays on the menu because
# it handles rotation, fractional scaling and touch input without being told,
# which is what one wants when the machine is used as a tablet.
#
# Caelestia is deliberately absent: it is tuned to Bebop and adds nothing here.
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

  # The Omnixy session needs OMNIXY_PATH before Hyprland parses its Lua, and
  # the quickshell process and every omnixy-* script inherit the PATH. dunst
  # is Type=dbus on org.freedesktop.Notifications: the first notification
  # of a session would bus-activate it ahead of the shell's own notification
  # server, so it is masked for the life of this session and released after.
  # This is the same wrapper as Bebop's in hosts/bebop/services.nix.
  omnixySession = pkgs.writeShellScript "hyprland-omnixy-session" ''
    export OMNIXY_PATH="${pkgs.omnixy-desktop}"
    export PATH="${pkgs.omnixy-desktop}/bin:${pkgs.omnixy-desktop.runtimePath}:$PATH"
    release() {
      systemctl --user stop omnixy-session.target 2>/dev/null || true
      systemctl --user unmask --runtime dunst.service 2>/dev/null || true
    }
    trap release EXIT INT TERM
    systemctl --user stop dunst.service 2>/dev/null || true
    systemctl --user mask --runtime dunst.service 2>/dev/null || true
    ${config.programs.hyprland.package}/bin/Hyprland --config "$HOME/.config/hypr/omnixy.lua"
  '';

  hyprlandSessions = pkgs.runCommand "hyprland-sessions" {
    passthru.providedSessions = [
      "hyprland-classic"
      "hyprland-omnixy"
    ];
  } ''
    mkdir -p $out/share/wayland-sessions
    cat > $out/share/wayland-sessions/hyprland-omnixy.desktop <<EOF
    [Desktop Entry]
    Type=Application
    Name=Hyprland (Omnixy)
    Comment=Hyprland with the Omnixy quickshell desktop
    Exec=${omnixySession}
    DesktopNames=Hyprland
    EOF
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
        # F2 opens the session menu. --cmd names Omnixy as the default until a
        # session has been remembered.
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember-session --sessions ${greeterSessions} --cmd ${omnixySession}";
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
