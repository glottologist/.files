{pkgs,lib, ...}: let
  inherit (import ./variables.nix) username;
  # Detect current session
  isHyprland =
    builtins.getEnv "XDG_CURRENT_DESKTOP"
    == "Hyprland"
    || builtins.getEnv "HYPRLAND_INSTANCE_SIGNATURE" != "";
  isKDE =
    builtins.getEnv "XDG_CURRENT_DESKTOP"
    == "KDE"
    || builtins.getEnv "KDE_FULL_SESSION" == "true";

  homeDirectory = "/home/${username}";
  configHome = "${homeDirectory}/.config";

  anthropic_api_key = pkgs.lib.removeSuffix "\n" (builtins.readFile ../../secrets/anthropic-api-key.txt);

  defaultPkgs = with pkgs; [
    any-nix-shell # fish support for nix shell
  ];
in {
  programs.home-manager = {
    enable = true;
  };

  home.enableNixpkgsReleaseCheck = false;
  # Conditional systemd targets based on session
  systemd.user.targets = lib.mkMerge [
    {
      tray = {
        Unit = {
          Description = "Home Manager System Tray";
          Requires = ["graphical-session-pre.target"];
        };
      };
    }
    (lib.mkIf isHyprland {
      hyprland-session.Unit.Wants = [
        "xdg-desktop-autostart.target"
      ];
    })
  ];

  qt.platformTheme =
    if isKDE
    then "kde"
    else "gtk2";

  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [
      "electron-12.2.3"
      "electron-13.6.9"
      "libgit2-0.27.10"
      #"python2.7-Pillow-6.2.2"
    ];
  };

  imports = [
    ../../secrets/accounts.nix
    ../../shared/ai/default.nix
    ../../shared/blockchain/default.nix
    ../../shared/blockchain/default.nix
    ../../shared/browsers/default.nix
    ../../shared/cloud/default.nix
    ../../shared/comics/default.nix
    ../../shared/communication/default.nix
    ../../shared/database/default.nix
    ../../shared/desktop/default.nix
    ../../shared/development/default.nix
    ../../shared/disk/default.nix
    ../../shared/documentation/default.nix
    ../../shared/fonts/default.nix
    ../../shared/keyboards/default.nix
    ../../shared/languages/default.nix
    ../../shared/learning/default.nix
    ../../shared/media/default.nix
    ../../shared/network/default.nix
    ../../shared/pentesting/default.nix
    ../../shared/pictures/default.nix
    ../../shared/productivity/default.nix
    ../../shared/security/default.nix
    ../../shared/storage/default.nix
    ../../shared/terminal/default.nix
    ../../shared/trading/default.nix
    ../../shared/virtualization/default.nix
    ../../shared/wm/default.nix
  ];

  xdg = {
    inherit configHome;
    enable = true;
  };

  home = {
    inherit username homeDirectory;

    packages = defaultPkgs;

    sessionVariables = {
      DISPLAY = ":0";
      EDITOR = "vim";
      BROWSER = "brave";
      TERMINAL = "foot";
      ANTHROPIC_API_KEY = anthropic_api_key;
    };
    pointerCursor = {
      gtk.enable = true;
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 22;
    };
    stateVersion = "25.05";
  };

  # Make home manager news silent
  news.display = "silent";
}
