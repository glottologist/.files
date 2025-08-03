{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  environment.systemPackages = with pkgs; [
    amfora # Fancy Terminal Browser For Gemini Protocol
    appimage-run # Needed For AppImage Support
    brave
    brightnessctl # For Screen Brightness Control
    cmatrix # Matrix Movie Effect In Terminal
    cowsay # Great Fun Terminal Program
    curl
    duf # Utility For Viewing Disk Usage In Terminal
    eza # Beautiful ls Replacement
    ffmpeg # Terminal Video / Audio Editing
    file-roller # Archive Manager
    gedit # Simple Graphical Text Editor
    gimp # Great Photo Editor
    git
    git-crypt
    gnome-keyring
    greetd.tuigreet # The Login Manager (Sometimes Referred To As Display Manager)
    htop # Simple Terminal Based System Monitor
    hyprpicker
    imv
    inxi
    jq
    kdePackages.kate
    killall
    libnotify
    libvirt
    lm_sensors
    lolcat
    lshw
    lxqt.lxqt-policykit
    meson
    mpv
    ncdu
    neovim
    ninja
    nixfmt-rfc-style
    pavucontrol
    pciutils
    picard
    pkg-config
    playerctl
    ripgrep
    termius # Modern cross device SSH Terminal
    socat
    unzip
    usbutils
    v4l-utils
    vim
    virt-viewer
    wget
    ytmdl
  ];

  programs = {
    ssh.askPassword = lib.mkForce "${pkgs.kdePackages.ksshaskpass}/bin/ksshaskpass";
    firefox.enable = true;
    fish.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true; # This handles the SSH_AUTH_SOCK setup
    };
    dconf.enable = true;
    hyprland.enable = true;
    seahorse.enable = true;
    hyprlock.enable = true;
    fuse.userAllowOther = true;
    virt-manager.enable = true;
    mtr.enable = true;
    adb.enable = true;
    thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        thunar-archive-plugin
        thunar-volman
      ];
    };
  };
}
