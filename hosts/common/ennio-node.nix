# The Ennio remote node daemon, so that Ennio on Bebop can dispatch agent
# sessions here. The daemon binds 127.0.0.1 in its own source and is reached
# through an SSH tunnel, so it needs no firewall rule and carries no bearer
# token: SSH is the authentication boundary.
#
# It exits after --idle-timeout seconds of inactivity by design; Restart makes
# that a restart rather than an outage.
{ pkgs, username, ennio, ... }:
let
  workspaceRoot = "/home/${username}/ennio-workspaces";
  package = ennio.packages.${pkgs.stdenv.hostPlatform.system}.ennio-node;
in
{
  systemd.services.ennio-node = {
    description = "Ennio remote node daemon";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [ git openssh tmux ];
    serviceConfig = {
      Type = "exec";
      User = username;
      Group = "users";
      WorkingDirectory = "/home/${username}";
      ExecStart =
        "${package}/bin/ennio-node"
        + " --port 9100"
        + " --idle-timeout 3600"
        + " --workspace-root ${workspaceRoot}";
      Restart = "always";
      RestartSec = "10s";
    };
  };

  systemd.tmpfiles.rules = [
    "d ${workspaceRoot} 0750 ${username} users -"
  ];
}
