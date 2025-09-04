{pkgs, ...}: let
  username = "jason";
  homeDirectory = "/home/${username}";
  configHome = "${homeDirectory}/.config";

  anthropic_api_key = pkgs.lib.removeSuffix "\n" (builtins.readFile ../secrets/anthropic-api-key.txt);
  gitty_key = pkgs.lib.removeSuffix "\n" (builtins.readFile ../secrets/github_gitty_token);

  defaultPkgs = with pkgs; [
    any-nix-shell # fish support for nix shell
  ];
in {
  programs.home-manager = {
    enable = true;
  };

  home.enableNixpkgsReleaseCheck = false;

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
    ../secrets/accounts.nix
    ../shared/fonts/default.nix
    ../shared/terminal/default.nix
    ../shared/ai/default.nix
    ../shared/blockchain/default.nix
    ../shared/browsers/default.nix
    ../shared/cloud/default.nix
    ../shared/comics/default.nix
    ../shared/communication/default.nix
    ../shared/database/default.nix
    ../shared/blockchain/default.nix
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
    ../shared/virtualization/default.nix
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
      GITTY_TOKENS = "github.com=${gitty_key}"
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
