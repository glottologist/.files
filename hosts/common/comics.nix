{
  config,
  lib,
  pkgs,
  username,
  modulesPath,
  ...
}: {
  services.komga = {
    enable = true;
    user = username;
    stateDir = "/var/lib/komga";
    settings.server.port = 9111;
    openFirewall = true;
  };
}
