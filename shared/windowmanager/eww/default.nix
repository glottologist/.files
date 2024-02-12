{
  config,
  lib,
  pkgs,
  stdenv,
  ...
}: let
  dependencies = with pkgs; [
    eww-wayland

    #gross

    bash
    blueberry
    bluez
    brillo
    coreutils
    dbus
    findutils
    gawk
    gnome.gnome-control-center
    gnused
    imagemagick
    jaq
    jc
    libnotify
    networkmanager
    pavucontrol
    playerctl
    procps
    pulseaudio
    ripgrep
    socat
    udev
    upower
    util-linux
    wget
    wireplumber
    wlogout
  ];

  reload_script = pkgs.writeShellScript "reload_eww" ''

     windows=$(${pkgs.eww-wayland}/bin/eww windows |`` ${pkgs.ripgrep}/bin/rg '\*' | tr -d '*')

    ${pkgs.systemd}/bin/systemctl --user restart eww.service

     echo $windows | while read -r w; do
       ${pkgs.eww-wayland}/bin/eww open $w
     done
  '';
in {
  home.packages = with pkgs; [
    eww-wayland
  ];
  imports = [
  ];
  xdg.configFile."eww" = {
    source = lib.cleanSourceWith {
      filter = name: _type: let
        baseName = baseNameOf (toString name);
      in
        !(lib.hasSuffix ".nix" baseName) && (baseName != "colors-dark.scss") && (baseName != "colors-light.scss");
      src = lib.cleanSource ./.;
    };

    # links each file individually, which lets us insert the colors file separately
    recursive = true;

   # onChange = reload_script.outPath;
  };
  # colors file
  xdg.configFile."eww/css/colors.scss".text = builtins.readFile ./css/colors-dark.scss;

  systemd.user.services.eww = {
    Unit = {
      Description = "Eww Daemon";
      # not yet implemented
      # PartOf = ["tray.target"];
      PartOf = ["graphical-session.target"];
    };
    Service = {
      Environment = "PATH=/run/wrappers/bin:${lib.makeBinPath dependencies}";
      ExecStart = "${pkgs.eww-wayland}/bin/eww daemon --no-daemonize";
      Restart = "on-failure";
    };
    Install.WantedBy = ["graphical-session.target"];
  };
}
