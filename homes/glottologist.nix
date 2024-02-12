{pkgs, ...}: let
  username = "glottologist";
  homeDirectory = "/home/${username}";
  configHome = "${homeDirectory}/.config";

  defaultPkgs = with pkgs; [
    any-nix-shell # fish support for nix shell
  ];
in {
  programs.home-manager = {
    enable = true;
  };

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
    ../shared/fonts/default.nix
    ../shared/terminal/default.nix
    ../shared/browsers/default.nix
    ../shared/cloud/default.nix
    ../shared/communication/default.nix
    ../shared/database/default.nix
    ../shared/desktop/default.nix
    ../shared/development/default.nix
    ../shared/disk/default.nix
    ../shared/documentation/default.nix
    ../shared/keyboards/default.nix
    ../shared/network/default.nix
    ../shared/learning/default.nix
    ../shared/languages/default.nix
    ../shared/media/default.nix
    ../shared/network/default.nix
    ../shared/pentesting/default.nix
    ../shared/pictures/default.nix
    ../shared/productivity/default.nix
    ../shared/security/default.nix
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
      EDITOR = "nvim";
    };
    pointerCursor = {
      gtk.enable = true;
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 22;
    };
    stateVersion = "23.05";
  };

  # Make home manager news silent
  news.display = "silent";
}
