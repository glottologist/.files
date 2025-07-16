{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  programs.nh = {
    enable = true;
  };
  environment.systemPackages = with pkgs; [
    nox # Tools to make nix nicer to use
    nix-tree # Interactively browse a Nix store paths dependencies
    nix-output-monitor
    nvd
  ];

  # Nix daemon config
  nix = {
    # Automate garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 2d";
    };

    # Automatically optimise nix store
    optimise.automatic = true;

    # Flakes settings

    # Avoid unwanted garbage collection when using nix-direnv
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs          = true
      keep-derivations      = true
      binary-caches-parallel-connections = 3
      connect-timeout = 5
    '';

    sshServe = {
      enable = true;
      keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILN1szb/fBxMMUgpClXaFd4zR71B5/02Ij9jV4wxKW+o jason@glottologist.co.uk"];
    };

    settings = {
      download-buffer-size = 250000000;
      auto-optimise-store = true;

      # Required by Cachix to be used as non-root user
      trusted-users = ["root" "jason" "glottologist"];

      access-tokens = [
       "github.com=${builtins.readFile ../../secrets/github-token}"
     ];

      substituters = [
        "https://claude-code.cachix.org"
        "https://nix-community.cachix.org"
        "https://cache.nixos.org/"
        "https://hyprland.cachix.org"
      ];

      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "claude-code.cachix.org-1:YeXf2aNu7UTX8Vwrze0za1WEDS+4DuI2kVeWEE4fsRk="
      ];

      experimental-features = ["nix-command" "flakes"];

      keep-outputs = true;
      keep-derivations = true;
      allow-import-from-derivation = true;
    };
  };
}
