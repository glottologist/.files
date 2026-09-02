# Syncthing paired with Bebop. Each host offers one folder named after itself,
# mirroring the arrangement Corvus uses.
#
# The GUI is loopback-only, unlike Corvus and Marauder, because those wildcard
# listeners have neither authentication nor TLS and these hosts are on public
# addresses; reach it with `ssh -L 8384:localhost:8384`.
#
# Devices and folders added at runtime are preserved: the reciprocal pairing on
# Bebop cannot be declared until these hosts have generated their device IDs.
{ config, lib, username, ... }:
let
  folder = lib.toUpper config.networking.hostName;
  syncRoot = "/home/${username}/syncthing";
in
{
  services.syncthing = {
    enable = true;
    user = username;
    group = "users";
    dataDir = syncRoot;
    configDir = "/home/${username}/.config/syncthing";
    openDefaultPorts = true;
    guiAddress = "127.0.0.1:8384";
    overrideDevices = false;
    overrideFolders = false;
    settings = {
      devices."BEBOP".id =
        "G4HR6SW-7L25Q2H-DIPVVRM-MKX3WMK-IN6M3GQ-Q6GDAUP-67NFG5R-DNZCNAY";
      folders.${folder} = {
        path = "${syncRoot}/${folder}";
        devices = [ "BEBOP" ];
      };
    };
  };

  # Syncthing 2.1 creates no default folder, so the directory must exist.
  systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true";

  systemd.tmpfiles.rules = [
    "d ${syncRoot} 0750 ${username} users -"
    "d ${syncRoot}/${folder} 0750 ${username} users -"
  ];
}
