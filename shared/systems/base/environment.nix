{
  config,
  pkgs,
  ...
}: {
  environment = {
    systemPackages = with pkgs; [
      cachix # Command line client for Nix binary cache hosting
      wget # Tool for retrieving files using HTTP, HTTPS, and FTP
      gnome.seahorse
    ];
  };
}
