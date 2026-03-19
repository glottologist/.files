{
  config,
  pkgs,
  username,
  ...
}: {
  imports = [
    ./boot.nix
    ./disko.nix
    ./hardware.nix
    ./location.nix
    ./networking.nix
    ./security.nix
    ./services.nix
    ./users.nix
    ../common/ai.nix
    ../common/development.nix
    ../common/nix.nix
  ];
  environment.pathsToLink = [ "/share/applications" "/share/xdg-desktop-portal" ];
  system = {
    stateVersion = "25.11";
  };
}
